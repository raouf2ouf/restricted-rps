import { memo, useState } from "react";

import "./MatchDisplay.scss";
import { IonButton, IonLabel, useIonModal } from "@ionic/react";
import { useAppDispatch, useAppSelector } from "$store/store";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import {
  cancelMatch,
  fetchMatchesForGame,
  selectMatchById,
  updateMatch,
} from "$store/matches.slice";
import { useAccount, useConfig, useWriteContract } from "wagmi";
import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";
import { MatchState } from "$models/Match";
import { cardToType } from "$models/Card";
import { lockOrUnlockCard } from "src/api/local";

type Props = {
  id: string;
  isPlayer?: boolean;
};

const GameDisplay: React.FC<Props> = ({ id, isPlayer }) => {
  const dispatch = useAppDispatch();
  const match = useAppSelector((state) => selectMatchById(state, id));

  const config = useConfig();
  const { writeContract } = useWriteContract();
  const { currentGameAddress } = useCurrentGameContext();

  async function cancelGame() {
    writeContract(
      {
        address: currentGameAddress as "0x${string}",
        abi: GAME_CONTRACT.abi,
        functionName: "cancelMatch",
        args: [match.matchId],
      },
      {
        onSuccess: async (data) => {
          dispatch(cancelMatch({ config, match }));
        },
        onError: (error) => {
          console.log(error);
          //TODO handle error
        },
      }
    );
  }

  function openModal() {}

  return (
    <>
      {match && (
        <div className="game">
          <div className="game-id column">
            <IonLabel className="label">
              <span className="hide-md">Match </span>ID
            </IonLabel>
            <IonLabel>{match.matchId}</IonLabel>
          </div>
          {isPlayer ? (
            <div className="game-players column">
              <IonLabel className="label">Card Played</IonLabel>
              <IonLabel>{cardToType(match.player1Card)}</IonLabel>
            </div>
          ) : (
            <div className="game-players column">
              <IonLabel className="label">Offered by</IonLabel>
              <IonLabel>Player {match.player1}</IonLabel>
            </div>
          )}
          <div className="game-cash column hide-md">
            <IonLabel className="label">
              <span className="hide-md">Bet</span>
            </IonLabel>
            <IonLabel>
              {match.player1Bet}/{match.player2Bet}
            </IonLabel>
          </div>
          {isPlayer ? (
            <IonButton
              // className="rectangle-button"
              fill="clear"
              onClick={cancelGame}
              color="danger"
            >
              <IonLabel>Cancel</IonLabel>
            </IonButton>
          ) : (
            <IonButton
              // className="rectangle-button"
              fill="clear"
              onClick={openModal}
            >
              <IonLabel>Answer</IonLabel>
            </IonButton>
          )}
        </div>
      )}
    </>
  );
};

export default memo(GameDisplay);
