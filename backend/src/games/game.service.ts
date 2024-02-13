import { Injectable } from '@nestjs/common';
import {
  generateHash,
  generateSecret,
  generateShuffledDeck,
  getPlayerCards,
  shuffleDeckUsingSeed,
} from '../services/game.utils';
import { ContractsService } from '../services/contracts.service';
import { Contract, ZeroAddress, AbiCoder, ZeroHash } from 'ethers';
import { Game, GameState, initGame } from 'src/entities/game.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as GAME_CONTRACT from '../contracts/RestrictedRPSGame.json';
import { ChainService } from '../services/chain.service';
import { ConfigService } from '../services/config.service';
import { encrypt, ECIES_CONFIG } from 'eciesjs';
import { initHistory, History } from 'src/entities/history.entity';
import { Cron, CronExpression } from '@nestjs/schedule';

type GameWithContract = {
  db: Game;
  contract?: Contract;
};

@Injectable()
export class GameService {
  public games: Map<string, GameWithContract>;

  constructor(
    @InjectRepository(Game)
    private readonly gamesRepository: Repository<Game>,
    @InjectRepository(History)
    private readonly historiesRepository: Repository<History>,
    private readonly contracts: ContractsService,
    private readonly chainService: ChainService,
    private readonly configService: ConfigService,
  ) {
    this.addFactoryEventListeners();
    this.getGames().then(() => {});
  }

  @Cron(CronExpression.EVERY_5_MINUTES)
  async handleVerifyingAndClosing() {
    const games = this.games.values();
    for (const game of games) {
      try {
        const shouldVerify = game.contract!.isReadyToVerify();
        if (shouldVerify) {
          const txVerify = await game.contract!.verifyDealerHonesty(
            game.db.initialDeck,
            game.db.secret,
          );
          await txVerify.wait();
          const txComputeRewards = await game.contract!.computeRewards();
          await txComputeRewards.wait();
          const txClose = await game.contract!.closeGame();
          await txClose.wait();
          const txPay = await game.contract!.payPlayers();
          await txPay.wait();
        }
      } catch (e) {}
    }
  }

  public async getHistory(playerAddress: string): Promise<History[]> {
    const histories: History[] = await this.historiesRepository.find({
      where: {
        chain: this.configService.CHAIN,
        address: playerAddress.toLowerCase(),
      },
    });
    return histories;
  }

  private addFactoryEventListeners() {
    // this.contracts.factory.on(
    //   'GameCreated',
    //   (gameId: bigint, gameAddress: string) =>
    //     this.onGameCreated(gameId, gameAddress),
    // );
  }

  // private async onGameCreated(gameId: bigint, gameAddress: string) {
  //   this.addGame(gameAddress);
  // }
  private createGameContract(address: string): Contract {
    const contract = new Contract(
      address,
      GAME_CONTRACT.abi,
      this.chainService.getSigner(),
    );
    contract.on(
      'GameJoined',
      (playerId: bigint, playerAddress: string, publicKey: string) => {
        this.onPlayerJoined(address, Number(playerId), publicKey);
      },
    );
    contract.on('GameClosed', async (state: bigint) => {
      console.log('game closed', state);
      const states: any[] = await contract.getPlayersState();
      console.log('states', states);
      const db = this.games.get(address).db;
      for (const state of states) {
        const his = initHistory({
          chain: this.configService.CHAIN,
          address: state.player.toLowerCase(),
          gameAddress: address,
          rewards: state.rewards,
          paidAmount: state.paidAmount,
          gameId: db.id,
        });
        db.state = GameState.CLOSED.toString();
        this.historiesRepository.save(his);
        this.gamesRepository.save(db);
        this.games.delete(address);
      }
      const tx = await contract.payPlayers();
      const receipt = tx.wait();
    });
    return contract;
  }
  private async onPlayerJoined(
    address: string,
    playerId: number,
    publicKey: string,
  ) {
    console.log('game joined');
    const gameWithContract = this.games.get(address);
    if (!gameWithContract) return;
    const { db: game, contract } = gameWithContract;
    if (!game) return;
    // get the seed
    const seed: bigint = await contract.getSeed();
    // shuffle the deck using the seed;
    const deck = shuffleDeckUsingSeed(game.initialDeck, seed);
    const playerCards = getPlayerCards(deck, playerId);
    let encryptedMsg = encrypt(publicKey, playerCards);
    const tx = await contract.setPlayerHand(playerId, encryptedMsg);
    await tx.wait();
    console.log('player was given hand: ', playerCards);
  }

  public async getGames() {
    this.games = new Map<string, GameWithContract>();
    const dbGames: Game[] = await this.gamesRepository.find({
      where: {
        chain: this.configService.CHAIN,
        state: GameState.OPEN.toString(),
      },
    });
    for (const dbGame of dbGames) {
      this.games.set(dbGame.address, { db: dbGame });
    }

    console.log('getting open games');
    const chainGames: string[] = await this.contracts.factory.getOpenGames();
    console.log('opengames', chainGames);

    for (const chainGameAddr of chainGames) {
      this.addGame(chainGameAddr);
    }

    console.log(this.games.keys());
  }

  private addGame(address: string) {
    if (this.games.has(address)) {
      const gameWithContract = this.games.get(address);
      if (!gameWithContract.contract) {
        gameWithContract.contract = this.createGameContract(address);
      }
    }
  }

  public async createGame(): Promise<string> {
    const deck = generateShuffledDeck();
    const secret = generateSecret();
    const hash = generateHash(deck, secret);
    const duration = 3;

    const tx = await this.contracts.factory.createGame(hash, duration, {
      value: 1,
    });
    const txReceipt = await tx.wait();
    const logs = txReceipt.logs;
    const eventFilter = await this.contracts.factory.filters
      .GameCreated()
      .getTopicFilter();
    const eventLogs = logs.filter((log) => log.topics[0] === eventFilter[0]);
    const topics = eventLogs[0].topics;
    const gameId = Number(BigInt(topics[1]));
    const gameAddress = '0x' + (topics[2] as string).substring(26);
    const game = initGame({
      id: gameId,
      chain: this.configService.CHAIN,
      initialDeck: deck.toString('hex'),
      secret,
      address: gameAddress,
    });
    const dbGame = await this.gamesRepository.save(game);
    this.games.set(gameAddress, { db: dbGame });
    this.addGame(gameAddress);

    if (this.configService.CHAIN == 'FOUNDRY') {
      console.log('trying to seed game');
      const requestId = ZeroHash;
      const airnode = ZeroAddress;
      const fulfillAddress = ZeroAddress;
      const fulfillFunctionId = '0x68795699';
      const seed = AbiCoder.defaultAbiCoder().encode(['uint256'], [0x666]);
      const signature = AbiCoder.defaultAbiCoder().encode(['uint8'], [0x0]);
      const seedTx = await this.contracts.airnodeMock!.fulfill(
        requestId,
        airnode,
        fulfillAddress,
        fulfillFunctionId,
        seed,
        signature,
      );
      const seedReceipt = await seedTx.wait();
      console.log(seedReceipt);
      // const logs = seedReceipt.logs;
      // console.log(seedReceipt);
      const seedGame = await this.games.get(gameAddress).contract!.getSeed();
      console.log('gameSeed: ', seedGame);
      const gameState = await this.games.get(gameAddress).contract!.getState();
      console.log('gameState: ', gameState);
    }
    return gameAddress;
  }
}
