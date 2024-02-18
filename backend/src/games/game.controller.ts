import { Body, Controller, Get, Param, Post } from '@nestjs/common';
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

  @Get('history/:address')
  async getGame(@Param('address') address: string) {
    console.log('getting history for', address);
    const histories = await this.game.getHistory(address);
    return histories;
  }

  @Post('matches/autoClose')
  async autoClose(@Body() data: any) {
    return this.game.setAutoClose(
      data.address,
      data.matchId,
      data.card,
      data.secret,
    );
  }
}
