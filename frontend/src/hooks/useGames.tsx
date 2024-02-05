import { useContractsContext } from "$contexts/ContractsContext";
import {
  useAccount,
  useConfig,
  useDisconnect,
  useReadContract,
  useWatchContractEvent,
} from "wagmi";
import * as FACTORY_CONTRACT from "$contracts/RestrictedRPSFactory.json";
import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";
import { GameInfo, GameInfoArray, gameArrayToGameInfo } from "$models/Game";
import { decryptForGame } from "src/api/local";
import { useAppDispatch } from "$store/store";
import { useEffect } from "react";
import {
  fetchPlayersStateForGame,
  setInitialPlayerHand,
} from "$store/playersState.slice";
import { fetchMatchesForGame } from "$store/matches.slice";

export function useOpenGames(): string[] | undefined {
  const { factoryAddress } = useContractsContext();

  const { data, refetch } = useReadContract({
    address: factoryAddress as "0x${string}",
    abi: FACTORY_CONTRACT.abi,
    functionName: "getOpenGames",
  });

  useWatchContractEvent({
    address: factoryAddress as "0x${string}",
    abi: FACTORY_CONTRACT.abi,
    onLogs(logs) {
      console.log(logs);
      refetch();
    },
  });

  return data as string[] | undefined;
}

export function useGame(gameAddress: "0x${string}"): GameInfo | undefined {
  const dispatch = useAppDispatch();
  const config = useConfig();
  const { address } = useAccount();
  const { data, refetch } = useReadContract({
    address: gameAddress as "0x${string}",
    abi: GAME_CONTRACT.abi,
    functionName: "getGameInfo",
  });

  useEffect(() => {
    dispatch(fetchPlayersStateForGame({ config, gameAddress }));
  }, []);

  useWatchContractEvent({
    address: gameAddress as "0x${string}",
    abi: GAME_CONTRACT.abi,
    onLogs(logs) {
      let shouldRefetch = false;
      console.log("logs", logs);
      for (const log of logs) {
        const eventName = (log as any).eventName;
        switch (eventName) {
          case "GameJoined":
            shouldRefetch = true;
            break;
          case "PlayerWasGivenHand":
            const args = (log as any).args as any;
            const topics = (log as any).topics as any;
            const playerAddress = "0x" + topics[1].substring(26);
            const encryptedHand = args.encryptedHand.slice(2);
            if (playerAddress.toLowerCase() == address?.toLowerCase()) {
              console.log("the player joined the game, decrypting");
              decryptForGame(
                address as string,
                gameAddress,
                encryptedHand
              ).then((hand) => {
                if (hand) {
                  console.log("dispatching");
                  dispatch(setInitialPlayerHand({ config, hand, gameAddress }));
                }
              });
            } else {
              dispatch(fetchPlayersStateForGame({ config, gameAddress }));
            }
            break;
          case "MatchCancelled":
            dispatch(fetchPlayersStateForGame({ config, gameAddress }));
            break;
          case "MatchAnswered":
          case "MatchCreated":
          case "MatchClosed":
            dispatch(fetchMatchesForGame({ config, gameAddress }));
            break;
        }
      }
      // TODO: optimizable by updating values rather than refetching;
      if (shouldRefetch) refetch();
    },
  });

  return data
    ? gameArrayToGameInfo(gameAddress, data as GameInfoArray)
    : undefined;
}
