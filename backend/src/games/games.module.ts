import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Game } from 'src/entities/game.entity';
import { GameService } from 'src/games/game.service';
import { ChainService } from 'src/services/chain.service';
import { ConfigService } from 'src/services/config.service';
import { ContractsService } from 'src/services/contracts.service';
import { GameController } from './game.controller';
import { History } from 'src/entities/history.entity';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [TypeOrmModule.forFeature([Game, History]), ScheduleModule],
  providers: [GameService, ContractsService, ChainService, ConfigService],
  controllers: [GameController],
})
export class GamesModule {}
