import { encrypt } from 'eciesjs';
import { AbiCoder, Contract, ZeroAddress, ZeroHash } from 'ethers';
import { Game } from 'src/entities/game.entity';
import { getPlayerCards, shuffleDeckUsingSeed } from 'src/services/game.utils';

export type GameWithContract = {
  db: Game;
  contract?: Contract;
};

export type PlayerState = {
  player: string;
  paidAmount: bigint;
  rewards: bigint;
  amountToPay: bigint;
  nbrStars: number;
  nbrStarsLocked: number;
  nbrCards: number;
  nbrRockUsed: number;
  nbrPaperUsed: number;
  nbrScissorsUsed: number;
  nbrOfferedMatches: number;
  initialNbrRock: number; // int8 rather than uint8 to avoid cast
  initialNbrPapers: number;
  initialNbrScissors: number;
  cheated: boolean;
  playerWasGivenCards: boolean;
};

export function stringToAddress(addressStr: string) {
  return ('0x' + (addressStr as string).substring(26)).toLowerCase();
}

export async function givePlayerHand(
  contract: Contract,
  game: Game,
  playerId: number,
  publicKey: string,
) {
  try {
    const seed: bigint = await contract.getSeed();
    // shuffle the deck using the seed;
    const deck = shuffleDeckUsingSeed(game.initialDeck, seed);
    const playerCards = getPlayerCards(deck, playerId);
    const encryptedMsg = encrypt(publicKey, playerCards);
    const tx = await contract.setPlayerHand(playerId, encryptedMsg);
    await tx.wait();
    console.log('player was given hand: ', playerCards);
  } catch (e) {
    console.error(e);
  }
}

export async function seedFoundryIfNecessary(
  chain: string,
  gameAddress: string,
  seed: number,
  airnodeMock: Contract,
) {
  if (chain == 'FOUNDRY') {
    console.log('seeding game');
    try {
      const requestId = ZeroHash;
      const airnode = ZeroAddress;
      const fulfillAddress = ZeroAddress;
      const fulfillFunctionId = '0x68795699';
      const encodedSeed = AbiCoder.defaultAbiCoder().encode(
        ['uint256'],
        [seed],
      );
      const signature = AbiCoder.defaultAbiCoder().encode(['uint8'], [0x0]);
      const seedTx = await airnodeMock.fulfill(
        requestId,
        airnode,
        fulfillAddress,
        fulfillFunctionId,
        encodedSeed,
        signature,
      );
      await seedTx.wait();
    } catch (e) {
      console.error(e);
    }
  }
}
