import {
  createAsyncThunk,
  createEntityAdapter,
  createSlice,
} from "@reduxjs/toolkit";
import { getHistory } from "src/api/server";
import { History } from "$models/History";

// API
export const fetchHistory = createAsyncThunk(
  "history/fetchHistory",
  async (playerAddress: string): Promise<History[]> => {
    const history = await getHistory(playerAddress);
    return history;
  }
);

// Adapter
const historiesAdapter = createEntityAdapter<History>({});

// Selectors
export const { selectAll: selectAllHistories, selectById: selectHistoryById } =
  historiesAdapter.getSelectors((state: any) => state.histories);

// Slice
type ExtraState = {};
export const historiesSlice = createSlice({
  name: "matches",
  initialState: historiesAdapter.getInitialState<ExtraState>({}),
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchHistory.fulfilled, (state, { payload }) => {
      historiesAdapter.upsertMany(state, payload);
    });
  },
});

export default historiesSlice.reducer;
