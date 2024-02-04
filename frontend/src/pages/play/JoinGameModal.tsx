import {
  IonBackdrop,
  IonButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonIcon,
  IonLabel,
  IonPage,
  IonRange,
  IonSpinner,
  IonTitle,
  IonToolbar,
} from "@ionic/react";
import {
  useAccount,
  useEstimateGas,
  useGasPrice,
  usePublicClient,
  useWriteContract,
} from "wagmi";
import { archiveSharp, arrowBackSharp, saveSharp } from "ionicons/icons";
import { memo, useEffect, useMemo, useState } from "react";
import SmallStars from "$ui/components/SmallStars/SmallStars";
import Tooltip from "$ui/components/Tooltip/Tooltip";

import * as GAME_CONTRACT from "$contracts/RestrictedRPSGame.json";

import "./JoinGameModal.scss";
import { useContractsContext } from "$contexts/ContractsContext";
import { wTe } from "$contracts/index";
import { GameInfo } from "$models/Game";
import { generateKeyPair, setPrivateKeyForGame } from "src/api/local";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";

type Props = {
  onDismiss: () => void;
  info: GameInfo;
};

const JoinGameModal: React.FC<Props> = ({ onDismiss, info }) => {
  const [loading, setLoading] = useState<boolean>(false);
  const [value, setValue] = useState<bigint>(BigInt(0));
  const [gasCost, setGasCost] = useState<bigint>(BigInt(0));
  const [cash, setCash] = useState<bigint>(BigInt(0));

  const { setCurrentGameAddressAndPlayerId } = useCurrentGameContext();

  const { collateralUnit } = useContractsContext();
  const { writeContract } = useWriteContract();
  const { address } = useAccount();

  const { publicKey, privateKey } = generateKeyPair();

  const client = usePublicClient();
  const { data: gasPrice } = useGasPrice();

  async function estimateGas(value: bigint) {
    return await client.estimateContractGas({
      address: info.address as "0x${string}",
      abi: GAME_CONTRACT.abi,
      functionName: "joinGame",
      value,
      args: [publicKey],
    });
  }

  useEffect(() => {
    let t: bigint = BigInt(info.starCost) * BigInt(3) + cash;
    estimateGas(t).then((gasEstimate) => {
      if (gasPrice !== undefined) {
        setGasCost(gasEstimate * gasPrice * 2n);
      }
    });
    setValue(t);
  }, [info, cash, gasPrice]);

  function handleSubmit() {
    setLoading(true);
    writeContract(
      {
        address: info.address as "0x${string}",
        abi: GAME_CONTRACT.abi,
        functionName: "joinGame",
        value: value,
        args: [publicKey],
      },
      {
        onSuccess: async (data) => {
          console.log("==========joined game", data);
          await setPrivateKeyForGame(address!, info.address, privateKey);
          setCurrentGameAddressAndPlayerId(info.address, info.players.length);
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
    <IonPage className="join-game-modal-page">
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonButton color="primary" onClick={closeModal} title="Close">
              <IonIcon icon={arrowBackSharp}></IonIcon>
            </IonButton>
          </IonButtons>
          <IonTitle>
            <span>Join Game </span>
            <IonLabel color="primary">{info.id}</IonLabel>
          </IonTitle>
          <IonButtons slot="end">
            <IonButton color="primary" onClick={handleSubmit}>
              <IonIcon slot="start" icon={archiveSharp}></IonIcon>
              <IonLabel>Join</IonLabel>
            </IonButton>
          </IonButtons>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <div className="join-game-modal-container">
          {loading && (
            <div className="join-game-modal-loading">
              <IonSpinner name="lines-sharp" color="primary"></IonSpinner>
              <IonBackdrop visible={true} tappable={false}></IonBackdrop>
            </div>
          )}
          <div className="title">
            <IonLabel>Collateral for Joining This Game</IonLabel>
            <Tooltip text="" />
          </div>
          <div className="cost stars-cost">
            <div className="what-you-get">
              <div className="cost-label">
                <IonLabel>Stars</IonLabel>
                <Tooltip text="" />
              </div>
              <div>
                <SmallStars nbr={3} expanded={3} direction="row" />
              </div>
            </div>
            <div className="what-you-pay">
              <div>{wTe(BigInt(info.starCost) * BigInt(3))}</div>
              <div className="unit">{collateralUnit}</div>
            </div>
          </div>

          <div className="cost cash-cost">
            <div className="what-you-get">
              <div className="cost-label">
                <IonLabel>Cash</IonLabel>
                <Tooltip text="" />
              </div>
              <IonRange
                ticks={false}
                snaps
                min={0}
                max={10}
                pin
                pinFormatter={(value: number) => `${value}M`}
                color="success"
                onIonChange={({ detail }) =>
                  setCash(
                    BigInt(detail.value as number) * BigInt(info.cashCost)
                  )
                }
              ></IonRange>
            </div>
            <div className="what-you-pay">
              <div>{wTe(cash)}</div>
              <div className="unit">{collateralUnit}</div>
            </div>
          </div>
          <div className="cost transaction-cost">
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
          </div>
          {/* <div className="keys">
            <IonLabel>{privateKey}</IonLabel>
          </div> */}
          <IonButton
            fill="clear"
            className="rectangle-button"
            onClick={handleSubmit}
          >
            <IonIcon slot="start" icon={archiveSharp}></IonIcon>
            <IonLabel>Join</IonLabel>
          </IonButton>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(JoinGameModal);
