import { readContract, Config } from "@wagmi/core";
import { PlayerState, buildPlayerStateId } from "$models/PlayerState";
import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";
import {
  createAsyncThunk,
  createEntityAdapter,
  createSelector,
  createSlice,
} from "@reduxjs/toolkit";
import { RootState } from "./store";
import { getMatchData, lockOrUnlockCard } from "src/api/local";
import { Match, MatchState, buildMatchId } from "$models/Match";
import { fetchPlayersStateForGame } from "./playersState.slice";

// API
const getMatchesForGame = async (
  config: Config,
  gameAddress: "0x${string}"
): Promise<Match[]> => {
  const matches: Match[] = [];
  const data = (await readContract(config, {
    address: gameAddress,
    abi: GAME_CONTRACT.abi,
    functionName: "getMatches",
  })) as any[];
  console.log(data);
  for (let i = 0; i < data.length; i++) {
    const d = data[i] as any;
    const m: Match = {
      id: buildMatchId(gameAddress, i),
      matchId: i,
      gameAddress,
      player1: d.player1,
      player2: d.player2,
      player1Card: d.player1Card,
      player2Card: d.player2Card,
      player1Bet: d.player1Bet,
      player2Bet: d.player2Bet,
      result: d.result,
    };
    matches.push(m);
  }
  return matches;
};

export const fetchMatchesForGame = createAsyncThunk(
  "matches/fetchMatchesForGame",
  async (
    {
      config,
      gameAddress,
    }: {
      config: Config;
      gameAddress: "0x${string}";
    },
    thunkAPI
  ): Promise<Match[]> => {
    const playerAddress = (thunkAPI.getState() as RootState).playersState
      .playerAddress;
    const matches = await getMatchesForGame(config, gameAddress);
    for (const match of matches) {
      if (
        playerAddress &&
        (match.result == MatchState.UNDECIDED ||
          match.result == MatchState.ANSWERED)
      ) {
        const data = await getMatchData(
          playerAddress,
          gameAddress,
          match.matchId
        );
        if (data) {
          match.secret = data.secret;
          match.player1Card = data.card;
        }
      }
    }
    await thunkAPI.dispatch(
      fetchPlayersStateForGame({ config, gameAddress: gameAddress })
    );
    console.log("matches", matches);
    return matches;
  }
);

export const cancelMatch = createAsyncThunk(
  "matches/cancelMatch",
  async (
    { config, match }: { config: Config; match: Match },
    thunkAPI
  ): Promise<string> => {
    const playerAddress = (thunkAPI.getState() as RootState).playersState
      .playerAddress;

    if (playerAddress) {
      await lockOrUnlockCard(
        playerAddress,
        match.gameAddress,
        match.player1Card,
        -1
      );
      await thunkAPI.dispatch(
        fetchPlayersStateForGame({ config, gameAddress: match.gameAddress })
      );
    }
    return match.id;
  }
);

// Adapter
const matchesAdapter = createEntityAdapter<Match>({
  sortComparer: (a: Match, b: Match) => b.matchId - a.matchId,
});

// Selectors
export const { selectAll: selectAllMatches, selectById: selectMatchById } =
  matchesAdapter.getSelectors((state: any) => state.matches);

export const selectMatchesForGame = createSelector(
  [selectAllMatches, (state, gameAddress: string) => gameAddress],
  (matches: Match[], gameAddress: string) => {
    const gAdr = gameAddress.toLowerCase();
    return matches.filter((m) => m.gameAddress.toLowerCase() == gAdr);
  }
);

// export const selectOpenMatchesForGameOfPlayer = createSelector(
//   [
//     selectAllMatches,
//     (state, gameAddress: string, playerId: number) => {
//       return { gameAddress, playerId };
//     },
//   ],
//   (matches: Match[], obj: any) => {
//     const gAdr = obj.gameAddress.toLowerCase();
//     return matches.filter(
//       (m) =>
//         m.gameAddress.toLowerCase() == gAdr &&
//         m.player1 == obj.playerId &&
//         m.result == MatchState.UNDECIDED
//     );
//   }
// );

// export const selectOpenMatchesForGameNotOfPlayer = createSelector(
//   [
//     selectAllMatches,
//     (state, gameAddress: string, playerId: number) => {
//       return { gameAddress, playerId };
//     },
//   ],
//   (matches: Match[], obj: any) => {
//     const gAdr = obj.gameAddress.toLowerCase();
//     return matches.filter(
//       (m) =>
//         m.gameAddress.toLowerCase() == gAdr &&
//         m.player1 != obj.playerId &&
//         m.result == MatchState.UNDECIDED
//     );
//   }
// );

// Slice
type ExtraState = {};
export const matchesSlice = createSlice({
  name: "matches",
  initialState: matchesAdapter.getInitialState<ExtraState>({}),
  reducers: {
    // setPlayerAddress: (state, { payload }) => {
    //   state.playerAddress = payload;
    // },
    updateMatch: (state, { payload }: { payload: Partial<Match> }) => {
      matchesAdapter.updateOne(state, { id: payload.id!, changes: payload });
    },
  },
  extraReducers: (builder) => {
    builder.addCase(fetchMatchesForGame.fulfilled, (state, { payload }) => {
      console.log("fetched games");
      matchesAdapter.upsertMany(state, payload);
    });
    builder.addCase(cancelMatch.fulfilled, (state, { payload }) => {
      matchesAdapter.updateOne(state, {
        id: payload,
        changes: { result: MatchState.CANCELLED },
      });
    });
  },
});

export const { updateMatch } = matchesSlice.actions;
export default matchesSlice.reducer;
