import { combineReducers, configureStore } from "@reduxjs/toolkit";
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";

import openGamesReducer from "./openGames.slice";
import playersStateReducer from "./playersState.slice";
import matchesReducer from "./matches.slice";

const rootReducer = combineReducers({
  openGames: openGamesReducer,
  playersState: playersStateReducer,
  matches: matchesReducer,
});

export const setupStore = (preloadedState?: any) => {
  return configureStore({
    reducer: rootReducer,
    preloadedState,
    devTools: process.env.NODE_ENV !== "production",
  });
};
export const store = setupStore();

export type RootState = ReturnType<typeof rootReducer>;
export type AppStore = ReturnType<typeof setupStore>;
export type AppDispatch = typeof store.dispatch;

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
