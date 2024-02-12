import { Injectable } from '@nestjs/common';
import { Contract } from 'ethers';
import { ConfigService } from './config.service';
import { ChainService } from './chain.service';
import * as FACTORY_CONTRACT from '../contracts/RestrictedRPSFactory.json';
import * as AIRNODE_MOCK_CONTRACT from '../contracts/AirnodeRrpV0Mock.json';

@Injectable()
export class ContractsService {
  public readonly factory: Contract;
  public readonly airnodeMock?: Contract;

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
    if (this.configService.CHAIN == 'FOUNDRY') {
      this.airnodeMock = new Contract(
        this.configService.AIRNODE_ADDRESS,
        AIRNODE_MOCK_CONTRACT.abi,
        this.chainService.getSigner(),
      );
    }
  }
}
