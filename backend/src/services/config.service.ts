import { Injectable } from '@nestjs/common';
import * as dotenv from 'dotenv';
dotenv.config();

@Injectable()
export class ConfigService {
  public readonly CHAIN: string;
  public readonly FACTORY_ADDRESS: string;
  public readonly PROVIDER_URL: string;
  public readonly WALLET_PRIVATE_KEY: string;
  public readonly DB_URL: string;

  constructor() {
    this.CHAIN = process.env.CHAIN || 'FOUNDRY';
    this.FACTORY_ADDRESS = process.env[`${this.CHAIN}_FACTORY_ADDRESS`];
    this.PROVIDER_URL = process.env[`${this.CHAIN}_PROVIDER`];
    this.WALLET_PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY;
    this.DB_URL = process.env.DB_URL;
  }
}
