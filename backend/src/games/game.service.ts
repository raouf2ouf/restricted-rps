import { Injectable } from '@nestjs/common';
import {
  generateHash,
  generateSecret,
  generateShuffledDeck,
} from '../services/game.utils';
import { ContractsService } from '../services/contracts.service';
import { Contract, ZeroAddress } from 'ethers';
import { Game, GameState, initGame } from 'src/entities/game.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as GAME_CONTRACT from '../contracts/RestrictedRPSGame.json';
import { ChainService } from '../services/chain.service';
import { ConfigService } from '../services/config.service';
import { initHistory, History } from 'src/entities/history.entity';
import { Cron, CronExpression } from '@nestjs/schedule';
import {
  GameWithContract,
  PlayerState,
  givePlayerHand,
  seedFoundryIfNecessary,
} from './games.utils';
import { Match, buildMatchId, initMatch } from 'src/entities/match.entity';

async function delay() {
  return new Promise<void>((resolve) => {
    setTimeout(() => {
      resolve();
    }, 20 * 1000);
  });
}

@Injectable()
export class GameService {
  public games: Map<string, GameWithContract>;

  constructor(
    @InjectRepository(Game)
    private readonly gamesRepository: Repository<Game>,
    @InjectRepository(History)
    private readonly historiesRepository: Repository<History>,
    @InjectRepository(Match)
    private readonly matchesRepository: Repository<Match>,
    private readonly contracts: ContractsService,
    private readonly chainService: ChainService,
    private readonly configService: ConfigService,
  ) {
    this.getGames().then(() => {});
  }

  private async verify(game: GameWithContract): Promise<boolean> {
    const shouldVerify: boolean = await game.contract.isReadyToVerify();
    if (shouldVerify) {
      console.log('1. Verifying!!');
      const txVerify = await game.contract!.verifyDealerHonesty(
        Buffer.from(game.db.initialDeck, 'hex'),
        game.db.secret,
      );
      try {
        await txVerify.wait();
        return true;
      } catch (e) {
        console.error(e);
      }
    }
    return false;
  }

  private async computeRewards(game: GameWithContract): Promise<boolean> {
    console.log('2. Computing rewards');
    const txComputeRewards = await game.contract!.computeRewards();
    try {
      await txComputeRewards.wait();
      return true;
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  private async closeGame(game: GameWithContract): Promise<boolean> {
    console.log('3. Closing');
    const txClose = await game.contract!.closeGame();
    try {
      await txClose.wait();
      return true;
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  private async payPlayers(game: GameWithContract): Promise<boolean> {
    console.log('4. Paying');
    const txPay = await game.contract!.payPlayers();
    try {
      await txPay.wait();
      return true;
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  @Cron(CronExpression.EVERY_10_MINUTES)
  async handleVerifyingAndClosing() {
    console.log('================== Starting CRON Job ======================');
    const games = this.games.values();
    if (this.games.size < 3) {
      try {
        const address = await this.createGame();
        console.log('++++++++ Created Game: ', address);
      } catch (e) {
        console.error(e);
      }
    }
    for (const game of games) {
      try {
        if (!game.contract) {
          console.log('no contract');
          continue;
        }
        console.log(`========== Game ${game.db.address} =================`);
        const state = Number(await game.contract!.getState());
        console.log(`===== State: ${state}`);
        if (state == GameState.CLOSED) {
          try {
            const states: PlayerState[] = await game.contract.getPlayersState();
            const db = game.db;
            for (const state of states) {
              const his = initHistory({
                chain: this.configService.CHAIN,
                address: state.player.toLowerCase(),
                gameAddress: db.address,
                rewards: BigInt(state.amountToPay).toString(),
                paidAmount: BigInt(state.paidAmount).toString(),
                gameId: db.id,
              });
              this.historiesRepository.save(his);
              this.gamesRepository.delete(db);
              this.games.delete(db.address);
            }
            // const tx = await contract.payPlayers();
            // tx.wait();
          } catch (e) {
            console.error(e);
          }

          continue;
        }
        const verifyRan: boolean = await this.verify(game);
        let computedRewards: boolean = false;
        if (verifyRan || state == GameState.DEALER_HONESTY_PROVEN) {
          await delay();
          computedRewards = await this.computeRewards(game);
        }
        let closedGame = false;
        if (
          computedRewards ||
          state == GameState.COMPUTED_REWARDS ||
          state == GameState.DEALER_CHEATED
        ) {
          await delay();
          closedGame = await this.closeGame(game);
        }
        let paidPlayers = false;
        if (closedGame || state == GameState.READY_TO_PAY) {
          await delay();
          paidPlayers = await this.payPlayers(game);
        }
        if (paidPlayers) {
          console.log('5. Done');
        }

        const playersStates: PlayerState[] =
          await game.contract!.getPlayersState();
        for (let i = 0; i < playersStates.length; i++) {
          const player = playersStates[i];
          if (!player.playerWasGivenCards) {
            console.log(
              '------------- Player was not given hand!! ---------------',
            );
            const eventFilter = await game.contract.filters
              .GameJoined()
              .getTopicFilter();
            const logs = await this.chainService.getProvider().getLogs({
              address: game.db!.address,
              topics: [eventFilter[0]],
              fromBlock: game.db.blockNumber,
              toBlock: 'latest',
            });
            for (const log of logs) {
              console.log('------------- gamejoined log ---------------------');
              const parsedLog = await game.contract.interface.parseLog({
                topics: [...log.topics],
                data: log.data,
              });
              console.log(log);
              const playerId = Number(parsedLog.args[0]);
              const publicKey = parsedLog.args[1];
              if (playerId == i) {
                this.onPlayerJoined(game.db.address, playerId, publicKey);
              }
            }
          }
        }
      } catch (e) {
        console.error(e);
      }
    }
  }

  public async getHistory(playerAddress: string): Promise<History[]> {
    const histories: History[] = await this.historiesRepository.find({
      where: {
        chain: this.configService.CHAIN,
        address: playerAddress.toLowerCase(),
      },
    });
    console.log(histories);
    return histories;
  }

  private createGameContract(address: string): Contract {
    const contract = new Contract(
      address,
      GAME_CONTRACT.abi,
      this.chainService.getSigner(),
    );

    contract.on('GameJoined', (playerId: bigint, publicKey: string) => {
      console.log('pub key: ', publicKey);
      this.onPlayerJoined(address, Number(playerId), publicKey);
    });

    contract.on('MatchAnswered', async (matchId: bigint) => {
      const autoCloseMatch = await this.matchesRepository.findOneBy({
        id: buildMatchId(address, Number(matchId)),
      });
      if (autoCloseMatch) {
        try {
          const tx = await contract.closeMatch(
            autoCloseMatch.matchId,
            autoCloseMatch.card,
            autoCloseMatch.secret,
          );
          await tx.wait();
          await this.matchesRepository.delete(autoCloseMatch);
        } catch (e) {
          console.error(e);
        }
      }
    });
    return contract;
  }

  private async onPlayerJoined(
    address: string,
    playerId: number,
    publicKey: string,
  ) {
    try {
      console.log('game joined');
      const gameWithContract = this.games.get(address);
      if (!gameWithContract) return;
      const { db: game, contract } = gameWithContract;
      if (!game) return;
      givePlayerHand(contract, game, playerId, publicKey);
    } catch (e) {
      console.error(e);
    }
  }

  public async getGames() {
    try {
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

      const chainGames: string[] = await this.contracts.factory.getGames();
      console.log('opengames', chainGames);

      for (const chainGameAddr of chainGames) {
        if (chainGameAddr != ZeroAddress) {
          this.addGame(chainGameAddr.toLowerCase());
        }
      }

      const games = this.games.values();

      for (const game of games) {
        if (!game.contract) {
          this.games.delete(game.db.address!);
          this.gamesRepository.delete(game.db);
        }
      }

      console.log(this.games.keys());
    } catch (e) {
      console.error(e);
    }
  }

  private addGame(address: string) {
    if (this.games.has(address)) {
      const gameWithContract = this.games.get(address);
      if (!gameWithContract.contract) {
        console.log('creating contract for', address);
        gameWithContract.contract = this.createGameContract(address);
      }
    }
  }

  public async createGame(): Promise<string> {
    console.log('=========== starting game creation ===========');
    const deck = generateShuffledDeck();
    const secret = generateSecret();
    const hash = generateHash(deck, secret);
    const duration = 3;
    let gameAddress = '';
    try {
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
      gameAddress = ('0x' + (topics[2] as string).substring(26)).toLowerCase();
      const game = initGame({
        id: gameId,
        chain: this.configService.CHAIN,
        initialDeck: deck.toString('hex'),
        secret,
        address: gameAddress,
        blockNumber: txReceipt.blockNumber,
      });
      await this.gamesRepository.delete({
        address: gameAddress,
        chain: this.configService.CHAIN,
      });
      const dbGame = await this.gamesRepository.save(game);
      this.games.set(gameAddress, { db: dbGame });
      this.addGame(gameAddress);

      console.log('created game', gameAddress);
      await seedFoundryIfNecessary(
        this.configService.CHAIN,
        gameAddress,
        0x666,
        this.contracts.airnodeMock!,
      );
    } catch (e) {
      console.error(e);
    }
    return gameAddress;
  }

  public async setAutoClose(
    address: string,
    matchId: number,
    card: number,
    secret: string,
  ) {
    try {
      console.log(address, matchId, card, secret);
      const match = initMatch({
        chain: this.configService.CHAIN,
        address,
        secret,
        card,
        matchId,
      });
      this.matchesRepository.save(match);
    } catch (e) {
      console.error(e);
    }
  }
}
