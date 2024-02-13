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

import "./OfferMatchModal.scss";
import { useContractsContext } from "$contexts/ContractsContext";
import { wTe } from "$contracts/index";
import { GameInfo } from "$models/Game";
import {
  generateKeyPair,
  setMatchData,
  setPrivateKeyForGame,
} from "src/api/local";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import { Match } from "$models/Match";
import { Card } from "$models/Card";
import { useAppDispatch, useAppSelector } from "$store/store";
import { selectPlayerStateById } from "$store/playersState.slice";
import { buildPlayerStateId } from "$models/PlayerState";
import StarSelector from "$ui/components/StarSelector/StarSelector";
import CardSelector from "$ui/components/CardSelector/CardSelector";
import { randomBytes } from "crypto";
import { concat, encodePacked, keccak256 } from "viem";
import { waitForTransactionReceipt } from "@wagmi/core";
import { fetchMatchesForGame } from "$store/matches.slice";

type Props = {
  onDismiss: () => void;
};

function computeHash(secret: string, card: Card): string {
  const encoder = new TextEncoder();
  return keccak256(concat([new Uint8Array([card]), encoder.encode(secret)]));
}
const OfferGameModal: React.FC<Props> = ({ onDismiss }) => {
  const dispatch = useAppDispatch();
  const [loading, setLoading] = useState<boolean>(false);
  const [disabled, setDisabled] = useState<boolean>(true);
  const [nbrStars, setNbrStars] = useState<number>(0);
  const [nbrStarsBet, setNbrStarsBet] = useState<number>(0);
  const [card, setCard] = useState<Card>();
  const [hash, setHash] = useState<string>();
  const [secret, setSecret] = useState<string>(randomBytes(7).toString("hex"));

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
    if (nbrStars > 0 && secret.length > 0 && card !== undefined)
      setDisabled(false);
    else setDisabled(true);
    setCard(card);
    if (secret) {
      setHash(computeHash(secret, card));
    }
  }

  function handleSetSecret(secret: string) {
    if (nbrStars > 0 && secret.length > 0 && card !== undefined)
      setDisabled(false);
    else setDisabled(true);
    setSecret(secret);
    if (card) {
      setHash(computeHash(secret, card));
    }
  }

  function handleSetNbrStars(nbrStars: number) {
    if (nbrStars > 0 && secret.length > 0 && card !== undefined)
      setDisabled(false);
    else setDisabled(true);
    setNbrStars(nbrStars);
  }

  function handleSubmit() {
    setLoading(true);
    console.log("card hash for:", card, secret, hash);
    writeContract(
      {
        address: currentGameAddress as "0x${string}",
        abi: GAME_CONTRACT.abi,
        functionName: "offerMatch",
        args: [hash, nbrStars, nbrStarsBet],
      },
      {
        onSettled: async (hash) => {
          const receipt = await waitForTransactionReceipt(config, {
            hash: hash as "0x${string}",
          });
          const matchId = Number(BigInt(receipt.logs[0].topics[1]!));
          console.log("matchId", matchId);
          await setMatchData(
            address!,
            currentGameAddress!,
            matchId,
            secret,
            card!
          );
          dispatch(
            fetchMatchesForGame({
              config,
              gameAddress: currentGameAddress as "0x${string}",
            })
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
    <IonPage className="offer-match-modal-page">
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonButton color="primary" onClick={closeModal} title="Close">
              <IonIcon icon={arrowBackSharp}></IonIcon>
            </IonButton>
          </IonButtons>
          <IonTitle>
            <span>Offer a Match </span>
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
        <div className="offer-match-modal-container">
          {loading && (
            <div className="offer-match-modal-loading">
              <IonSpinner name="lines-sharp" color="primary"></IonSpinner>
              <IonBackdrop visible={true} tappable={false}></IonBackdrop>
            </div>
          )}
          <div className="title">
            <IonLabel>Offer a Match</IonLabel>
            <Tooltip text="" />
          </div>
          <div className="item player1bet">
            <div className="item-label">
              <IonLabel>Your Bet</IonLabel>
              <Tooltip text="" />
            </div>
            <div className="item-data">
              <StarSelector
                max={
                  playerState
                    ? playerState.nbrStars - playerState.nbrStarsLocked
                    : 0
                }
                onSelect={handleSetNbrStars}
              />
            </div>
          </div>
          <div className="item player2bet">
            <div className="item-label">
              <IonLabel>Opponent Min Bet</IonLabel>
              <Tooltip text="" />
            </div>
            <div className="item-data">
              <StarSelector max={5} onSelect={setNbrStarsBet} />
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
          <div className="item secret">
            <div className="item-label">
              <IonLabel>Secret</IonLabel>
              <Tooltip text="" />
            </div>
            <div className="item-data">
              <IonInput
                value={secret}
                onIonChange={({ detail }) =>
                  handleSetSecret(detail.value || "")
                }
                placeholder="Secret to construct Hash"
              />
            </div>
          </div>

          {/* <div className="cost transaction-cost">
            <div className="what-you-get">
              <div className="cost-label">
                <IonLabel>Estimated Transaction Gas Cost</IonLabel>
                <Tooltip text="" />
              </div>
            </div>
            <div className="what-you-pay">
              <div>{wTe(gasCost)}</div>
              <div className="unit">{collateralUnit}</div>
            </div>
          </div>

          <div className="total">
            <IonLabel>Total</IonLabel>
            <IonLabel color="primary">
              ~{wTe(value + gasCost)} {collateralUnit}
            </IonLabel>
          </div> */}
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

export default memo(OfferGameModal);
