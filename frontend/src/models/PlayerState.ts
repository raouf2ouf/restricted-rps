export interface PlayerState {
  id: string;
  gameAddress: string;
  playerAddress: string;
  playerId: number;
  nbrCards: number;
  nbrStars: number;
  nbrStarsLocked: number;
  nbrRockUsed: number;
  nbrPaperUsed: number;
  nbrScissorsUsed: number;
  initialRock?: number;
  initialPaper?: number;
  initialScissors?: number;
  lockedRock?: number;
  lockedPaper?: number;
  lockedScissors?: number;
}
export function buildPlayerStateId(gameAddress: string, playerAddress: string) {
  return `${gameAddress.toLowerCase()}-${playerAddress.toLowerCase()}`;
}
