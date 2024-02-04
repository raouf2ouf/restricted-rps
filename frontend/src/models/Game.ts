export interface Game {
  id: number;
  address: string;
}

export type GameInfoArray = [
  number | undefined, // gameId
  number | undefined, // nbrPlayers
  number | undefined, // nbrMatches
  number | undefined, // duration
  bigint | undefined, // starCost
  bigint | undefined, // 1M cash cost
  string[] // players
];

export interface GameInfo {
  id: number;
  address: "0x${string}";
  nbrPlayers: number;
  nbrMatches: number;
  duration: number;
  starCost: string;
  cashCost: string;
  players: string[];
}

export function gameArrayToGameInfo(
  address: string,
  data: GameInfoArray
): GameInfo {
  return {
    address: address as "0x${string}",
    id: data[0]!,
    nbrPlayers: data[1]!,
    nbrMatches: data[2]!,
    duration: data[3]!,
    starCost: data[4]!.toString(),
    cashCost: data[5]!.toString(),
    players: data[6],
  };
}
