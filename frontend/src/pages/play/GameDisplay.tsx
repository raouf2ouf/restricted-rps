import { memo } from "react";

import "./GameDisplay.scss";
import { IonButton, IonLabel, useIonModal } from "@ionic/react";
import JoinGameModal from "./JoinGameModal";
import { useAppSelector } from "$store/store";
import { selectOpenGameById } from "$store/openGames.slice";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";

type Props = {
  id: number;
  isPlayer?: boolean;
  playerId?: number;
};

const GameDisplay: React.FC<Props> = ({ id, isPlayer, playerId }) => {
  const { setCurrentGameAddressAndPlayerId } = useCurrentGameContext();
  const info = useAppSelector((state) => selectOpenGameById(state, id));

  const [present, dismiss] = useIonModal(JoinGameModal, {
    onDismiss: (data: string, role: string) => dismiss(data, role),
    info: info!,
  });

  function openJoinModal() {
    present();
  }

  function selectGame() {
    setCurrentGameAddressAndPlayerId(info.address, playerId!);
  }
  return (
    <>
      {info && (
        <div className="game">
          <div className="game-id column">
            <IonLabel className="label">
              <span className="hide-md">Game </span>ID
            </IonLabel>
            <IonLabel>{info.id}</IonLabel>
          </div>
          <div className="game-players column">
            <IonLabel className="label">Players</IonLabel>
            <IonLabel>{info.nbrPlayers}/6</IonLabel>
          </div>
          <div className="game-cash column hide-md">
            <IonLabel className="label">
              Matches <span className="hide-md">Played</span>
            </IonLabel>
            <IonLabel>{info.nbrMatches}</IonLabel>
          </div>
          <div className="game-duration column">
            <IonLabel className="label">Duration</IonLabel>
            <IonLabel>{info.duration}</IonLabel>
          </div>
          {isPlayer ? (
            <IonButton
              // className="rectangle-button"
              fill="clear"
              onClick={selectGame}
            >
              <IonLabel>Select</IonLabel>
            </IonButton>
          ) : (
            <IonButton
              // className="rectangle-button"
              fill="clear"
              onClick={openJoinModal}
            >
              <IonLabel>Join</IonLabel>
            </IonButton>
          )}
        </div>
      )}
    </>
  );
};

export default memo(GameDisplay);
