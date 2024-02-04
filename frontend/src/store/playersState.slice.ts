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
import { getPlayerStateForGame, setPlayerStateForGame } from "src/api/local";

// API
const getPlayersStates = async (
  config: Config,
  gameAddress: "0x${string}"
): Promise<PlayerState[]> => {
  const playersStates: PlayerState[] = [];
  const data = (await readContract(config, {
    address: gameAddress,
    abi: GAME_CONTRACT.abi,
    functionName: "getPlayersState",
  })) as any[];
  for (let i = 0; i < data.length; i++) {
    const d = data[i] as any;
    const state: PlayerState = {
      id: buildPlayerStateId(gameAddress, d.player),
      gameAddress,
      playerAddress: d.player,
      playerId: i,
      nbrCards: d.nbrCards,
      nbrStars: d.nbrStars,
      nbrStarsLocked: d.nbrStarsLocked,
      nbrRockUsed: d.nbrRockUsed,
      nbrPaperUsed: d.nbrPaperUsed,
      nbrScissorsUsed: d.nbrScissorsUsed,
    };
    playersStates.push(state);
  }
  return playersStates;
};
export const fetchPlayersStateForGame = createAsyncThunk(
  "playersState/updatePlayerState",
  async (
    {
      config,
      gameAddress,
    }: {
      config: Config;
      gameAddress: "0x${string}";
    },
    thunkAPI
  ): Promise<PlayerState[]> => {
    const playerAddress = (thunkAPI.getState() as RootState).playersState
      .playerAddress;
    const playersStates = await getPlayersStates(config, gameAddress);
    const currentPlayerState = playersStates.find(
      (s) => s.playerAddress.toLowerCase() == playerAddress?.toLowerCase()
    );
    if (currentPlayerState) {
      const hand = await getPlayerStateForGame(playerAddress!, gameAddress);
      if (hand) {
        Object.assign(currentPlayerState, hand);
      }
    }
    return playersStates;
  }
);

export const setInitialPlayerHand = createAsyncThunk(
  "playersState/setInitialPlayerHand",
  async (
    {
      config,
      hand,
      gameAddress,
    }: { config: Config; hand: number[]; gameAddress: "0x${string}" },
    thunkAPI
  ): Promise<PlayerState | undefined> => {
    const state = thunkAPI.getState() as RootState;
    const playerAddress = state.playersState.playerAddress!;
    await setPlayerStateForGame(playerAddress, gameAddress, {
      initialRock: hand[0],
      initialPaper: hand[1],
      initialScissors: hand[2],
    });
    const playersStates = await getPlayersStates(config, gameAddress);
    const playerState = playersStates.find(
      (s) => s.playerAddress.toLowerCase() == playerAddress?.toLowerCase()
    );
    let cp: PlayerState | undefined;
    if (playerState) {
      cp = { ...playerState };
      cp.initialRock = hand[0];
      cp.initialPaper = hand[1];
      cp.initialScissors = hand[2];
    }
    return cp;
  }
);

// Adapter
const playersStateAdapter = createEntityAdapter<PlayerState>({});

// Selectors
export const {
  selectAll: selectAllPlayersStates,
  selectById: selectPlayerStateById,
} = playersStateAdapter.getSelectors((state: any) => state.playersState);

export const selectPlayersStateForGame = createSelector(
  [selectAllPlayersStates, (state, gameAddress: string) => gameAddress],
  (playersStates: PlayerState[], gameAddress: string) => {
    const gAdr = gameAddress.toLowerCase();
    return playersStates.filter(
      (playerState) => playerState.gameAddress.toLowerCase() == gAdr
    );
  }
);

// Slice
type ExtraState = {
  playerAddress?: string;
};
export const playersStateSlice = createSlice({
  name: "playersState",
  initialState: playersStateAdapter.getInitialState<ExtraState>({}),
  reducers: {
    setPlayerAddress: (state, { payload }) => {
      state.playerAddress = payload;
    },
    upsertPlayerState: (state, { payload }: { payload: PlayerState }) => {
      playersStateAdapter.upsertOne(state, payload);
    },
  },
  extraReducers: (builder) => {
    builder.addCase(
      fetchPlayersStateForGame.fulfilled,
      (state, { payload }) => {
        playersStateAdapter.upsertMany(state, payload);
      }
    );
    builder.addCase(setInitialPlayerHand.fulfilled, (state, { payload }) => {
      if (payload) {
        playersStateAdapter.upsertOne(state, payload);
      }
    });
  },
});

export const { upsertPlayerState, setPlayerAddress } =
  playersStateSlice.actions;
export default playersStateSlice.reducer;
