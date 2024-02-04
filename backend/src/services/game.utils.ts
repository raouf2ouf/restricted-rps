import { randomBytes } from 'crypto';
import { solidityPackedKeccak256 } from 'ethers';

export enum Card {
  ROCK = 0,
  PAPER = 1,
  SCISSORS = 2,
}

const INITIAL_DECK = 'AAAAA8555555000000';

export function generateSecret(): string {
  const nbrCharacters: number = Math.floor(Math.random() * (10 - 6 + 1) + 6);
  const secret = randomBytes(nbrCharacters).toString('hex');
  return secret;
}

export function generateShuffledDeck(): Buffer {
  const deck = Buffer.from(INITIAL_DECK, 'hex');
  for (let i = 35; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const cardI = getCard(deck, i);
    const cardJ = getCard(deck, j);

    setCard(deck, i, cardJ);
    setCard(deck, j, cardI);
  }
  return deck;
}

export function cardToString(card: Card): string {
  switch (card) {
    case 0:
      return 'ROCK';
    case 1:
      return 'PAPER';
    default:
      return 'SCISSORS';
  }
}

export function readableDeck(deck: Buffer) {
  const cards: string[] = [];
  for (let i = 35; i >= 0; i--) {
    const card = getCard(deck, i);
    cards.push(cardToString(card));
  }
  return cards;
}

export function generateHash(deck: Buffer, secret: string): string {
  const hash = solidityPackedKeccak256(['bytes9', 'string'], [deck, secret]);
  return hash;
}

export function setCard(deck: Buffer, position: number, card: Card): Buffer {
  const byteIndex = Math.floor(position / 4);
  const bitOffset = (position % 4) * 2;

  deck.writeUint8(
    (deck.readUint8(byteIndex) & ~(0b11 << bitOffset)) | (card << bitOffset),
    byteIndex,
  );
  return deck;
}

export function getCard(deck: Buffer, position: number): Card {
  const byteIndex = Math.floor(position / 4);
  const bitOffset = (position % 4) * 2;
  return (deck.readUint8(byteIndex) >> bitOffset) & 0b11;
}

export function getPlayerCards(
  deck: Buffer,
  playerId: number,
  cardsPerPlayer: number = 6,
): Uint8Array {
  const cards = new Uint8Array(3);
  const start = playerId * cardsPerPlayer; //CARDS_PER_PLAYER
  for (let i = 0; i < cardsPerPlayer; i++) {
    const cardIdx = start + i;
    const card = getCard(deck, cardIdx);
    cards[card]++;
  }
  return cards;
}
