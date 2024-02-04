import { Injectable } from '@nestjs/common';
import { Contract } from 'ethers';
import { ConfigService } from './config.service';
import { ChainService } from './chain.service';
import * as FACTORY_CONTRACT from '../contracts/RestrictedRPSFactory.json';
import * as GAME_CONTRACT from '../contracts/RestrictedRPSGame.json';
import { encrypt } from 'eciesjs';

@Injectable()
export class ContractsService {
  public readonly factory: Contract;

  public games: Map<string, Contract>;

  constructor(
    private readonly configService: ConfigService,
    private readonly chainService: ChainService,
  ) {
    this.factory = new Contract(
      this.configService.FACTORY_ADDRESS,
      FACTORY_CONTRACT.abi,
      this.chainService.getSigner(),
    );
  }
}
