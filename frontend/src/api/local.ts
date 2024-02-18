import { Card } from "$models/Card";
import { Storage, Drivers } from "@ionic/storage";
import { PrivateKey, decrypt, encrypt, ECIES_CONFIG } from "eciesjs";

const storage = new Storage({
  name: "ethpoir",
  driverOrder: [Drivers.IndexedDB, Drivers.LocalStorage],
});
storage.create();

export async function setLastBlockNumber(
  wallet: string,
  gameAddress: string,
  blocknumber: bigint
) {
  await storage.set(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-blocknumber`,
    blocknumber
  );
}
export async function getLastBlockNumber(
  wallet: string,
  gameAddress: string
): Promise<bigint> {
  const res = (await storage.get(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-blocknumber`
  )) as bigint | undefined;
  return BigInt(res || 0);
}

export async function setMatchData(
  wallet: string,
  gameAddress: string,
  matchId: number,
  secret: string,
  card: Card
): Promise<void> {
  await lockOrUnlockCard(wallet, gameAddress, matchId, card, 1);
  await storage.set(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}`,
    { secret, card }
  );
}
export async function getMatchData(
  wallet: string,
  gameAddress: string,
  matchId: number
): Promise<{ secret: string; card: Card } | undefined> {
  return (await storage.get(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}`
  )) as { secret: string; card: Card } | undefined;
}

export async function getPlayerStateForGame(
  wallet: string,
  gameAddress: string
): Promise<
  | {
      initialRock?: number;
      initialPaper?: number;
      initialScissors?: number;
      lockedRock?: number;
      lockedPaper?: number;
      lockedScissors?: number;
    }
  | undefined
> {
  return (await storage.get(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-hand`
  )) as
    | {
        initialRock?: number;
        initialPaper?: number;
        initialScissors?: number;
        lockedRock?: number;
        lockedPaper?: number;
        lockedScissors?: number;
      }
    | undefined;
}

export async function setPlayerStateForGame(
  wallet: string,
  gameAddress: string,
  obj: {
    initialRock?: number;
    initialPaper?: number;
    initialScissors?: number;
    lockedRock?: number;
    lockedPaper?: number;
    lockedScissors?: number;
  }
) {
  await storage.set(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-hand`,
    obj
  );
}

export async function unlockCardsIfNecessary(
  wallet: string,
  gameAddress: string,
  matchId: number
) {
  const isLocked = await storage.get(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}-lock`
  );
  if (isLocked && isLocked.locked) {
    await lockOrUnlockCard(wallet, gameAddress, matchId, isLocked.card, -1);
  }
}

export async function lockOrUnlockCard(
  wallet: string,
  gameAddress: string,
  matchId: number,
  card: Card,
  nbr: number
) {
  const isLocked = await storage.get(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}-lock`
  );
  if (isLocked && !isLocked.locked && nbr < 0) return;
  if (nbr > 0) {
    // locking
    await storage.set(
      `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}-lock`,
      {
        locked: true,
        card,
      }
    );
  } else {
    // unlocking
    await storage.set(
      `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-${matchId}-lock`,
      { locked: false }
    );
  }
  let existingState = await getPlayerStateForGame(wallet, gameAddress);
  if (existingState) {
    switch (card) {
      case Card.ROCK:
        existingState.lockedRock = (existingState.lockedRock || 0) + nbr;
        break;
      case Card.PAPER:
        existingState.lockedPaper = (existingState.lockedPaper || 0) + nbr;
        break;
      case Card.SCISSORS:
        existingState.lockedScissors =
          (existingState.lockedScissors || 0) + nbr;
        break;
    }
    await storage.set(
      `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-hand`,
      existingState
    );
  }
}

export async function getPrivateKeyForGame(
  wallet: string,
  gameAddress: string
): Promise<string | undefined> {
  const key = `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-pk`;
  console.log("getting private key for: ", key);
  return (await storage.get(key)) as string | undefined;
}
export async function setPrivateKeyForGame(
  wallet: string,
  gameAddress: string,
  privateKey: string
): Promise<void> {
  await storage.set(
    `${wallet.toLowerCase()}-${gameAddress.toLowerCase()}-pk`,
    privateKey
  );
}

export async function decryptForGame(
  wallet: string,
  gameAddress: string,
  encryptedMsg: string
) {
  const privateKey = await getPrivateKeyForGame(wallet, gameAddress);
  console.log("private key", privateKey);
  if (!privateKey) return;
  const b = Buffer.from(privateKey, "hex");
  const binaryData = Buffer.from(encryptedMsg, "hex");
  const encryptedMsgArray = new Uint8Array(binaryData);
  const result = decrypt(b, encryptedMsgArray);
  const cards = new Uint8Array(result);
  return [cards[0], cards[1], cards[2]];
}

export function generateKeyPair(): {
  privateKey: string;
  publicKey: string;
} {
  const sk = new PrivateKey();
  const privateKey = sk.secret.toString("hex");
  // const privateKey = sk.toHex();
  const publicKey = sk.publicKey.uncompressed.toString("hex");
  return { publicKey, privateKey };
}
