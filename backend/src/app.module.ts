import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigService } from './services/config.service';
import { ChainService } from './services/chain.service';
import { ContractsService } from './services/contracts.service';
import { join } from 'path';
import { ServeStaticModule } from '@nestjs/serve-static';
import { Pool } from 'pg';
import { GameService } from './games/game.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { dataSourceOptions } from 'db/db-config';
import { Game } from './entities/game.entity';
import { GamesModule } from './games/games.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({ ...dataSourceOptions, entities: [Game] }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'www'),
      exclude: ['/api*'],
    }),
    GamesModule,
  ],
  providers: [],
})
export class AppModule {}
