import { GameInfo } from "$models/Game";
import {
  createEntityAdapter,
  createSelector,
  createSlice,
} from "@reduxjs/toolkit";

// Adapter
const openGamesAdapter = createEntityAdapter<GameInfo>({
  //@ts-ignore
  selectId: (game: GameInfo) => game.id,
  sortComparer: (a, b) => a.id - b.id,
});

// Selectors
export const { selectAll: selectAllOpenGames, selectById: selectOpenGameById } =
  openGamesAdapter.getSelectors((state: any) => state.openGames);

export const selectAllPlayerGames = createSelector(
  [
    selectAllOpenGames,
    (state, playerAddress: string | undefined) => playerAddress,
  ],
  (openGames, playerAddress) => {
    if (!playerAddress) return [];
    return openGames.filter((g) => g.players.includes(playerAddress));
  }
);

export const selectAllOtherGames = createSelector(
  [
    selectAllOpenGames,
    (state, playerAddress: string | undefined) => playerAddress,
  ],
  (openGames, playerAddress) => {
    if (!playerAddress) return [];
    return openGames.filter((g) => !g.players.includes(playerAddress));
  }
);

// Slice
export const openGamesSlice = createSlice({
  name: "openGames",
  initialState: openGamesAdapter.getInitialState({}),
  reducers: {
    setAllOpenGames: (state, { payload }) => {
      openGamesAdapter.setAll(state, payload);
    },
    upsertOpenGame: (state, { payload }) => {
      openGamesAdapter.upsertOne(state, payload);
    },
    removeOpenGame: (state, { payload }) => {
      openGamesAdapter.removeOne(state, payload);
    },
  },
});

export const { setAllOpenGames, upsertOpenGame, removeOpenGame } =
  openGamesSlice.actions;
export default openGamesSlice.reducer;
