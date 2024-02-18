import { Column, Entity, PrimaryColumn } from 'typeorm';
import { Base } from './base.entity';

@Entity()
export class Match extends Base {
  @PrimaryColumn('varchar', { length: 200, nullable: false })
  id: string;

  @Column('varchar', { length: 100, nullable: false })
  chain: string;

  @Column('varchar', { length: 60, nullable: false })
  address: string;

  @Column({ type: 'int', nullable: false })
  matchId: number;

  @Column({ type: 'int', nullable: false })
  card: number;

  @Column('varchar', { length: 100, nullable: false })
  secret: string;
}

export function initMatch(obj: {
  chain: string;
  address: string;
  card: number;
  secret: string;
  matchId: number;
}): Match {
  const db = new Match();
  db.id = buildMatchId(obj.address, obj.matchId);
  db.address = obj.address.toLowerCase();
  db.chain = obj.chain;
  db.secret = obj.secret;
  db.card = obj.card;
  db.matchId = obj.matchId;
  return db;
}

export function buildMatchId(address: string, matchId: number) {
  return `${address.toLowerCase()}-${matchId}`;
}
