import { Injectable } from '@nestjs/common';
import {
  generateHash,
  generateSecret,
  generateShuffledDeck,
  getPlayerCards,
} from '../services/game.utils';
import { ContractsService } from '../services/contracts.service';
import { Contract } from 'ethers';
import { Game, GameState, initGame } from 'src/entities/game.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as GAME_CONTRACT from '../contracts/RestrictedRPSGame.json';
import { ChainService } from '../services/chain.service';
import { ConfigService } from '../services/config.service';
import { encrypt, ECIES_CONFIG } from 'eciesjs';

type GameWithContract = {
  db: Game;
  contract?: Contract;
};

// for tests
async function delay(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

@Injectable()
export class GameService {
  public games: Map<string, GameWithContract>;

  constructor(
    @InjectRepository(Game)
    private readonly gamesRepository: Repository<Game>,
    private readonly contracts: ContractsService,
    private readonly chainService: ChainService,
    private readonly configService: ConfigService,
  ) {
    this.addFactoryEventListeners();
    this.getGames().then(() => {});
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
    console.log('seeting listener');
    contract.on(
      'GameJoined',
      (playerId: bigint, playerAddress: string, publicKey: string) => {
        this.onPlayerJoined(address, Number(playerId), publicKey);
      },
    );
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
    const playerCards = getPlayerCards(
      Buffer.from(game.initialDeck, 'hex'),
      playerId,
    );
    let encryptedMsg = encrypt(publicKey, playerCards);
    // delay(1000);
    const tx = await contract.setPlayerHand(playerId, encryptedMsg);
    const txReceipt = await tx.wait();
    console.log('player was given hand: ', playerCards);
  }

  public async getGames() {
    this.games = new Map<string, GameWithContract>();
    const dbGames: Game[] = await this.gamesRepository.find({
      where: {
        chain: this.configService.CHAIN,
        state: GameState.OPEN,
      },
    });
    for (const dbGame of dbGames) {
      this.games.set(dbGame.address, { db: dbGame });
    }

    const chainGames: string[] = await this.contracts.factory.getOpenGames();

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

    const tx = await this.contracts.factory.createGame(hash, 1, { value: 1 });
    const txReceipt = await tx.wait();
    console.log('receipt');
    console.log(txReceipt);
    const topics = txReceipt.logs[0].topics;
    const gameId = Number(BigInt(topics[1]));
    const gameAddress = '0x' + (topics[2] as string).substring(26);
    const game = initGame({
      id: gameId,
      chain: this.configService.CHAIN,
      initialDeck: deck.toString('hex'),
      secret,
      address: gameAddress,
    });
    console.log(game);
    const dbGame = await this.gamesRepository.save(game);
    this.games.set(gameAddress, { db: dbGame });
    this.addGame(gameAddress);
    return gameAddress;
  }
}
