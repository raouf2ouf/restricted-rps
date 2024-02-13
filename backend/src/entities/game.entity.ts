import { Column, Entity } from 'typeorm';
import { Base } from './base.entity';

export enum GameState {
  OPEN = 0,
  WAITING_FOR_SEED,
  DEALER_CHEATED,
  DEALER_HONESTY_PROVEN,
  COMPUTED_REWARDS,
  CLOSED,
}

@Entity()
export class Game extends Base {
  @Column({ type: 'int' })
  id: number;

  @Column('varchar', { length: 100, nullable: false })
  chain: string;

  @Column('varchar', { length: 60, nullable: false })
  address: string;

  @Column('varchar', { length: 100, nullable: false })
  initialDeck: string;

  @Column('varchar', { length: 100, nullable: false })
  secret: string;

  @Column('varchar', { length: 100, nullable: true })
  shuffledDeck: string;

  @Column({
    type: 'enum',
    enum: GameState,
    nullable: false,
    default: GameState.OPEN,
  })
  state: string;
}

export function initGame(obj: {
  id: number;
  chain: string;
  address: string;
  initialDeck: string;
  secret: string;
}): Game {
  const game = new Game();
  game.address = obj.address;
  game.id = obj.id;
  game.state = GameState.OPEN.toString();
  game.chain = obj.chain;
  game.initialDeck = obj.initialDeck;
  game.secret = obj.secret;
  return game;
}
