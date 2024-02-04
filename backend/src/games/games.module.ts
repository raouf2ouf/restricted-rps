import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Game } from 'src/entities/game.entity';
import { GameService } from 'src/games/game.service';
import { ChainService } from 'src/services/chain.service';
import { ConfigService } from 'src/services/config.service';
import { ContractsService } from 'src/services/contracts.service';
import { GameController } from './game.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Game])],
  providers: [GameService, ContractsService, ChainService, ConfigService],
  controllers: [GameController],
})
export class GamesModule {}
