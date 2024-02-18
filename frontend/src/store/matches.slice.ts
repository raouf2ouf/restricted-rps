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
import {
  getMatchData,
  lockOrUnlockCard,
  unlockCardsIfNecessary,
} from "src/api/local";
import { Match, MatchState, buildMatchId } from "$models/Match";
import { fetchPlayersStateForGame } from "./playersState.slice";
import { Card } from "$models/Card";

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

export const unlockCardsOfMatch = createAsyncThunk(
  "matches/unlockCardsOfMatch",
  async (
    {
      config,
      gameAddress,
      matchId,
    }: {
      config: Config;
      gameAddress: "0x${string}";
      matchId: number;
    },
    thunkApi
  ): Promise<void> => {
    const state = thunkApi.getState() as RootState;
    const playerAddress = state.playersState.playerAddress?.toLowerCase();
    if (!playerAddress) return;
    const matches: Record<string, Match> = state.matches.entities;
    const match = matches[buildMatchId(gameAddress, matchId)];
    const states: PlayerState[] = Object.values(state.playersState.entities);
    const playerState = states.find(
      (s) => s.playerAddress.toLowerCase() == playerAddress
    );
    if (playerState) {
      const playerId = playerState.playerId;
      if (match.player1 == playerId) {
        await lockOrUnlockCard(
          playerAddress,
          gameAddress,
          matchId,
          match.player1Card,
          -1
        );
      } else if (match.player2 == playerId) {
        await lockOrUnlockCard(
          playerAddress,
          gameAddress,
          matchId,
          match.player2Card,
          -1
        );
      }
    }
  }
);

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
      } else if (playerAddress) {
        try {
          await unlockCardsIfNecessary(
            playerAddress,
            gameAddress,
            match.matchId
          );
        } catch (e) {
          console.error(e);
        }
      }
    }
    await thunkAPI.dispatch(
      fetchPlayersStateForGame({ config, gameAddress: gameAddress })
    );
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
        match.matchId,
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

export const selectOpenMatchesForGameOfPlayer = createSelector(
  [
    (state, gameAddress: string, playerId) =>
      selectMatchesForGame(state, gameAddress),
    (state, gameAddress: string, playerId: number) => {
      return playerId;
    },
  ],
  (matches: Match[], playerId: number) => {
    return matches.filter(
      (m) => m.player1 == playerId && m.result == MatchState.UNDECIDED
    );
  }
);

export const selectOpenMatchesForGameOfNotPlayer = createSelector(
  [
    (state, gameAddress: string, playerId) =>
      selectMatchesForGame(state, gameAddress),
    (state, gameAddress: string, playerId: number) => {
      return playerId;
    },
  ],
  (matches: Match[], playerId: number) => {
    return matches.filter(
      (m) => m.player1 != playerId && m.result == MatchState.UNDECIDED
    );
  }
);

export const selectAnsweredMatchesForGameOfPlayer = createSelector(
  [
    (state, gameAddress: string, playerId) =>
      selectMatchesForGame(state, gameAddress),
    (state, gameAddress: string, playerId: number) => {
      return playerId;
    },
  ],
  (matches: Match[], playerId: number) => {
    return matches.filter(
      (m) => m.player1 == playerId && m.result == MatchState.ANSWERED
    );
  }
);

export const selectPlayedMatchesForGame = createSelector(
  [(state, gameAddress: string) => selectMatchesForGame(state, gameAddress)],
  (matches: Match[]) => {
    return matches.filter((m) => m.result >= MatchState.DRAW);
  }
);
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
