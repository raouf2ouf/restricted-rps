import { Controller, Get, Param } from '@nestjs/common';
import { GameService } from './game.service';

@Controller('api')
export class GameController {
  constructor(private readonly game: GameService) {}

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

  @Get('create-game')
  async createGame(): Promise<any> {
    const txReceipt = await this.game.createGame();
    return txReceipt;
  }

  @Get('history/:address')
  async getGame(@Param('address') address: string) {
    const histories = await this.game.getHistory(address);
    return histories;
  }
}
