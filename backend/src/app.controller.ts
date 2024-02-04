import { Controller, Get, Param } from '@nestjs/common';
import { AppService } from './app.service';
import { solidityPackedKeccak256 } from 'ethers';
import { ContractsService } from './services/contracts.service';
import { GameService } from './games/game.service';
import { generateShuffledDeck, readableDeck } from './services/game.utils';

@Controller('api')
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly contracts: ContractsService,
    private readonly game: GameService,
  ) {}

  @Get()
  async getHello(): Promise<any> {
    // const deck = generateShuffledDeck();
    // return {
    //   deck: deck.toString('hex'),
    //   readable: readableDeck(deck),
    // };
    // const res = await this.contracts.getGames();
    // console.log(res);
    // return res;
  }

  // @Get('create-game')
  // async createGame(): Promise<any> {
  //   const txReceipt = await this.game.createGame();
  //   return txReceipt;
  // }

  // @Get('get-game/:id')
  // async getGame(@Param('id') id: number) {
  //   console.log(id);
  //   return this.game.getGame(id);
  // }
}
