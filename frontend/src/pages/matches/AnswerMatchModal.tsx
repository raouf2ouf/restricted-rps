import {
  IonBackdrop,
  IonButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonIcon,
  IonInput,
  IonLabel,
  IonPage,
  IonRange,
  IonSpinner,
  IonTitle,
  IonToolbar,
} from "@ionic/react";
import {
  useAccount,
  useConfig,
  useEstimateGas,
  useGasPrice,
  usePublicClient,
  useWriteContract,
} from "wagmi";
import {
  archiveSharp,
  arrowBackSharp,
  saveSharp,
  sendSharp,
} from "ionicons/icons";
import { memo, useEffect, useMemo, useState } from "react";
import SmallStars from "$ui/components/SmallStars/SmallStars";
import Tooltip from "$ui/components/Tooltip/Tooltip";

import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";

import "./AnswerMatchModal.scss";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import { Match } from "$models/Match";
import { Card } from "$models/Card";
import { useAppDispatch, useAppSelector } from "$store/store";
import { selectPlayerStateById } from "$store/playersState.slice";
import { buildPlayerStateId } from "$models/PlayerState";
import CardSelector from "$ui/components/CardSelector/CardSelector";
import { fetchMatchesForGame } from "$store/matches.slice";
import { lockOrUnlockCard } from "src/api/local";

type Props = {
  onDismiss: () => void;
  match: Match;
};

const AnswerMatchModal: React.FC<Props> = ({ onDismiss, match }) => {
  const dispatch = useAppDispatch();
  const [loading, setLoading] = useState<boolean>(false);
  const [disabled, setDisabled] = useState<boolean>(true);
  const [card, setCard] = useState<Card>();

  const { writeContract } = useWriteContract();
  const config = useConfig();

  const { currentGameAddress } = useCurrentGameContext();
  const { address } = useAccount();
  const playerState = useAppSelector((state) =>
    selectPlayerStateById(
      state,
      buildPlayerStateId(currentGameAddress || "", address || "")
    )
  );

  function handleSetCard(card: Card) {
    if (card !== undefined) setDisabled(false);
    else setDisabled(true);
    setCard(card);
  }

  function handleSubmit() {
    setLoading(true);
    writeContract(
      {
        address: currentGameAddress as "0x${string}",
        abi: GAME_CONTRACT.abi,
        functionName: "answerMatch",
        args: [match.matchId, card],
      },
      {
        onSuccess: async (data) => {
          lockOrUnlockCard(address!, match.gameAddress, card!, -1);
          dispatch(
            fetchMatchesForGame({ config, gameAddress: match.gameAddress })
          );
          closeModal();
        },
        onError: (error) => {
          console.log(error);
          setLoading(false);
          //TODO handle error
        },
      }
    );
  }

  function closeModal() {
    onDismiss();
  }
  return (
    <IonPage className="answer-match-modal-page">
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonButton color="primary" onClick={closeModal} title="Close">
              <IonIcon icon={arrowBackSharp}></IonIcon>
            </IonButton>
          </IonButtons>
          <IonTitle>
            <span>Answer Match</span>{" "}
            <IonLabel color="primary">{match.matchId}</IonLabel>
          </IonTitle>
          <IonButtons slot="end">
            <IonButton
              color="primary"
              onClick={handleSubmit}
              disabled={disabled}
            >
              <IonIcon slot="start" icon={sendSharp}></IonIcon>
              <IonLabel>Submit</IonLabel>
            </IonButton>
          </IonButtons>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <div className="answer-match-modal-container">
          {loading && (
            <div className="answer-match-modal-loading">
              <IonSpinner name="lines-sharp" color="primary"></IonSpinner>
              <IonBackdrop visible={true} tappable={false}></IonBackdrop>
            </div>
          )}
          <div className="title">
            <IonLabel>Answer Match</IonLabel>
            <Tooltip text="" />
          </div>
          <div className="item player1bet">
            <div className="item-label">
              <IonLabel>Your Bet</IonLabel>
              <Tooltip text="" />
            </div>
            <div className="item-data">
              <SmallStars direction="row" nbr={match.player2Bet} expanded={5} />
            </div>
          </div>
          <div className="item card">
            <div className="item-label">
              <IonLabel>Card To Play</IonLabel>
              <Tooltip text="" />
            </div>
            <div className="item-data">
              <CardSelector
                onSelect={handleSetCard}
                nbrRocks={
                  playerState
                    ? playerState.initialRock! -
                      playerState.nbrRockUsed -
                      (playerState.lockedRock || 0)
                    : 0
                }
                nbrPapers={
                  playerState
                    ? playerState.initialPaper! -
                      playerState.nbrPaperUsed -
                      (playerState.lockedPaper || 0)
                    : 0
                }
                nbrScissors={
                  playerState
                    ? playerState.initialScissors! -
                      playerState.nbrScissorsUsed -
                      (playerState.lockedScissors || 0)
                    : 0
                }
              />
            </div>
          </div>

          <IonButton
            fill="clear"
            className="rectangle-button"
            onClick={handleSubmit}
            disabled={disabled}
          >
            <IonIcon slot="start" icon={sendSharp}></IonIcon>
            <IonLabel>Submit</IonLabel>
          </IonButton>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(AnswerMatchModal);
