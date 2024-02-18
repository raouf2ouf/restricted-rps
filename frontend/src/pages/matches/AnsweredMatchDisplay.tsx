import { memo, useState } from "react";

import "./AnsweredMatchDisplay.scss";
import { IonButton, IonIcon, IonLabel, useIonModal } from "@ionic/react";
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
import { MatchState, resultToText } from "$models/Match";
import { cardToType } from "$models/Card";
import AnswerMatchModal from "./AnswerMatchModal";
import SmallCard from "$ui/components/SmallCard/SmallCard";

type Props = {
  id: string;
  isPlayer?: boolean;
};

const AnsweredMatchDisplay: React.FC<Props> = ({ id, isPlayer }) => {
  const dispatch = useAppDispatch();
  const match = useAppSelector((state) => selectMatchById(state, id));

  const config = useConfig();
  const { writeContract } = useWriteContract();
  const { currentGameAddress } = useCurrentGameContext();
  const { address } = useAccount();

  const [present, dismiss] = useIonModal(AnswerMatchModal, {
    onDismiss: (data: string, role: string) => dismiss(data, role),
    match,
  });

  async function closeMatch() {
    writeContract(
      {
        address: currentGameAddress as "0x${string}",
        abi: GAME_CONTRACT.abi,
        functionName: "closeMatch",
        args: [match.matchId, match.player1Card, match.secret!],
      },
      {
        onSuccess: async (data) => {
          dispatch(
            fetchMatchesForGame({ config, gameAddress: match.gameAddress })
          );
        },
        onError: (error) => {
          console.log(error);
          //TODO handle error
        },
      }
    );
  }

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
          <div className="card column">
            <IonLabel className="label">Player {match.player1}</IonLabel>
            {isPlayer && match.result == MatchState.ANSWERED && (
              <SmallCard simple card={match.player1Card} />
            )}
            {!isPlayer && match.result == MatchState.ANSWERED && (
              <IonLabel>?</IonLabel>
            )}
            {!isPlayer && match.result != MatchState.ANSWERED && (
              <SmallCard simple card={match.player1Card} />
            )}
          </div>
          <div className="card column">
            <IonLabel className="label">Player {match.player2}</IonLabel>
            <SmallCard simple card={match.player2Card} />
          </div>
          <div className="game-cash column hide-md">
            <IonLabel className="label">
              <span className="hide-md">Bet</span>
            </IonLabel>
            <IonLabel>
              {match.player1Bet}/{match.player2Bet}
            </IonLabel>
          </div>

          <div className="game-id column">
            <IonLabel className="label">Result</IonLabel>
            <IonLabel className={`result ${resultToText(match.result)}`}>
              {resultToText(match.result)}
            </IonLabel>
          </div>

          {isPlayer && match.result == MatchState.ANSWERED && (
            <IonButton
              // className="rectangle-button"
              fill="clear"
              onClick={closeMatch}
              color="warning"
            >
              <IonLabel>Close</IonLabel>
            </IonButton>
          )}
        </div>
      )}
    </>
  );
};

export default memo(AnsweredMatchDisplay);
