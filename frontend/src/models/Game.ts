export interface Game {
  id: number;
  address: string;
}

export type GameInfoArray = [
  number | undefined, // gameId
  number | undefined, // nbrPlayers
  number | undefined, // nbrMatches
  bigint | undefined, // starCost
  bigint | undefined, // 1M cash cost
  bigint | undefined, // endtime
  string[] // players
];

export interface GameInfo {
  id: number;
  address: "0x${string}";
  nbrPlayers: number;
  nbrMatches: number;
  starCost: string;
  cashCost: string;
  endTimestamp: number;
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
    starCost: data[3]!.toString(),
    cashCost: data[4]!.toString(),
    endTimestamp: Number(data[5]),
    players: data[6],
  };
}
