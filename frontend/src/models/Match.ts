import { Card } from "./Card";

export enum MatchState {
  UNDECIDED = 0,
  ANSWERED,
  CANCELLED,
  DRAW,
  WIN1, // win for player 1
  WIN2, // win for player 2
}

export interface Match {
  id: string;
  matchId: number;
  gameAddress: "0x${string}";
  player1: number;
  player2: number;
  player1Card: Card;
  player2Card: Card;
  player1Bet: number;
  player2Bet: number;
  result: MatchState;
  secret?: string;
}

export function buildMatchId(gameAddress: string, matchId: number) {
  return `${gameAddress.toLowerCase()}-${matchId}`;
}
