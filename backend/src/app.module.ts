import { Module } from '@nestjs/common';
import { join } from 'path';
import { ServeStaticModule } from '@nestjs/serve-static';
import { TypeOrmModule } from '@nestjs/typeorm';
import { dataSourceOptions } from 'db/db-config';
import { Game } from './entities/game.entity';
import { GamesModule } from './games/games.module';
import { History } from './entities/history.entity';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    TypeOrmModule.forRoot({ ...dataSourceOptions, entities: [Game, History] }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'www'),
      exclude: ['/api*'],
    }),
    ScheduleModule.forRoot(),
    GamesModule,
  ],
  providers: [],
})
export class AppModule {}
