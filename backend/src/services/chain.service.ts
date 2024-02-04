import { Injectable } from '@nestjs/common';
import {
  Signer,
  Provider,
  AlchemyProvider,
  Wallet,
  JsonRpcProvider,
} from 'ethers';
import { ConfigService } from './config.service';

@Injectable()
export class ChainService {
  private readonly provider: Provider;
  private readonly signer: Signer;

  constructor(private readonly configService: ConfigService) {
    if (this.configService.CHAIN == 'FOUNDRY') {
      this.provider = new JsonRpcProvider(this.configService.PROVIDER_URL);
    } else {
      this.provider = new AlchemyProvider(this.configService.PROVIDER_URL);
    }
    const wallet = new Wallet(this.configService.WALLET_PRIVATE_KEY);
    this.signer = wallet.connect(this.provider);
  }

  getProvider(): Provider {
    return this.provider;
  }

  getSigner(): Signer {
    return this.signer;
  }
}
