import { Column, Entity } from 'typeorm';
import { Base } from './base.entity';

@Entity()
export class History extends Base {
  @Column({ type: 'int' })
  id: number;

  @Column('varchar', { length: 100, nullable: false })
  chain: string;

  @Column('varchar', { length: 60, nullable: false })
  address: string;

  @Column('varchar', { length: 60, nullable: false })
  gameAddress: string;

  @Column({ type: 'int', nullable: false })
  gameId: number;

  @Column({ type: 'varchar', nullable: false })
  paidAmount: string;

  @Column('varchar', { length: 100, nullable: false })
  rewards: string;
}

export function initHistory(obj: {
  chain: string;
  address: string;
  gameAddress: string;
  gameId: number;
  paidAmount: string;
  rewards: string;
}): History {
  const his = new History();
  his.chain = obj.chain;
  his.address = obj.address;
  his.gameAddress = obj.gameAddress;
  his.gameId = obj.gameId;
  his.paidAmount = obj.paidAmount;
  his.rewards = obj.rewards;
  return his;
}
