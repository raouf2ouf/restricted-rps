import { useContractsContext } from "$contexts/ContractsContext";
import {
  Config,
  useAccount,
  useConfig,
  useReadContract,
  useWatchContractEvent,
} from "wagmi";
import { getClient, getBlockNumber } from "@wagmi/core";
import { getLogs } from "viem/actions";

import * as FACTORY_CONTRACT from "$contracts/RestrictedRPSFactory.json";
import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";
import { GameInfo, GameInfoArray, gameArrayToGameInfo } from "$models/Game";
import {
  decryptForGame,
  getLastBlockNumber,
  setLastBlockNumber,
} from "src/api/local";
import { useAppDispatch } from "$store/store";
import { useEffect } from "react";
import {
  fetchPlayersStateForGame,
  setInitialPlayerHand,
} from "$store/playersState.slice";
import { fetchMatchesForGame, unlockCardsOfMatch } from "$store/matches.slice";

export function useOpenGames(): string[] | undefined {
  const { factoryAddress } = useContractsContext();

  console.log("factoryAddress", factoryAddress);
  // fetch open games
  const { data, refetch } = useReadContract({
    address: factoryAddress as "0x${string}",
    abi: FACTORY_CONTRACT.abi,
    functionName: "getOpenGames",
  });

  useWatchContractEvent({
    address: factoryAddress as "0x${string}",
    abi: FACTORY_CONTRACT.abi,
    onLogs(logs) {
      console.log("logs from factory", logs);
      refetch();
    },
  });

  console.log("games", data);

  return data as string[] | undefined;
}

export function useGame(gameAddress: "0x${string}"): GameInfo | undefined {
  const dispatch = useAppDispatch();
  const config = useConfig();
  const { address } = useAccount();
  // fetch game info
  const { data, refetch } = useReadContract({
    address: gameAddress as "0x${string}",
    abi: GAME_CONTRACT.abi,
    functionName: "getGameInfo",
  });

  // fetch player state
  useEffect(() => {
    dispatch(fetchPlayersStateForGame({ config, gameAddress }));
  }, []);
  useEffect(() => {
    if (config && address) {
      checkMissedLogs(address!, gameAddress, config, dispatch).then(() => {
        console.log("checked missed logs");
      });
    }
  }, [config, address]);

  useWatchContractEvent({
    address: gameAddress as "0x${string}",
    abi: GAME_CONTRACT.abi,
    onLogs(logs) {
      let shouldRefetch = false;
      console.log("game logs", logs);
      for (const log of logs) {
        const shouldUpdate = handleGameLog(
          log,
          dispatch,
          address!,
          gameAddress,
          config
        );
        if (shouldUpdate) {
          shouldRefetch = true;
        }
        const eventName = (log as any).eventName;
        const args = (log as any).args as any;
        const topics = (log as any).topics as any;
        switch (eventName) {
          case "GameJoined":
            shouldRefetch = true;
            break;
          case "PlayerWasGivenHand":
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
            dispatch(fetchMatchesForGame({ config, gameAddress }));
            break;
          case "MatchClosed":
            dispatch(fetchMatchesForGame({ config, gameAddress }));
            dispatch(
              unlockCardsOfMatch({
                config,
                gameAddress,
                matchId: Number(topics[1]),
              })
            );
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

async function checkMissedLogs(
  wallet: string,
  gameAddress: "0x${string}",
  config: any,
  dispatch: any
) {
  const client = getClient(config);
  let lastBlockNumber = BigInt(await getLastBlockNumber(wallet, gameAddress));
  const blockNumber = await getBlockNumber(config);
  if (lastBlockNumber == BigInt(0)) {
    lastBlockNumber = blockNumber - BigInt(100);
  }
  if (lastBlockNumber == blockNumber) return;
  const logs = await getLogs(client, {
    address: gameAddress,
    fromBlock: BigInt(lastBlockNumber),
    toBlock: blockNumber,
  });
  for (const log of logs) {
    console.log(log);
    handleGameLog(log, dispatch, wallet, gameAddress, config);
  }
  await setLastBlockNumber(wallet, gameAddress, blockNumber);
}

function handleGameLog(
  log: any,
  dispatch: any,
  address: string,
  gameAddress: "0x${string}",
  config: Config
): boolean {
  let shouldRefetch = false;
  const eventName = log.eventName;
  const args = (log as any).args as any;
  const topics = (log as any).topics as any;
  switch (eventName) {
    case "GameJoined":
      shouldRefetch = true;
      break;
    case "PlayerWasGivenHand":
      const playerAddress = "0x" + topics[1].substring(26);
      const encryptedHand = args.encryptedHand.slice(2);
      if (playerAddress.toLowerCase() == address?.toLowerCase()) {
        console.log("the player joined the game, decrypting");
        decryptForGame(address as string, gameAddress, encryptedHand).then(
          (hand) => {
            if (hand) {
              dispatch(setInitialPlayerHand({ config, hand, gameAddress }));
            }
          }
        );
      } else {
        dispatch(fetchPlayersStateForGame({ config, gameAddress }));
      }
      break;
    case "MatchCancelled":
      dispatch(fetchPlayersStateForGame({ config, gameAddress }));
      break;
    case "MatchAnswered":
    case "MatchCreated":
      dispatch(fetchMatchesForGame({ config, gameAddress }));
      break;
    case "MatchClosed":
      dispatch(fetchMatchesForGame({ config, gameAddress }));
      dispatch(
        unlockCardsOfMatch({
          config,
          gameAddress,
          matchId: Number(topics[1]),
        })
      );
      break;
  }
  return shouldRefetch;
}
