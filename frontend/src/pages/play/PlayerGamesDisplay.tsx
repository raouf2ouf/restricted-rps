import { memo } from "react";

import "./GameDisplay.scss";
import { IonButton, IonLabel } from "@ionic/react";
import { GameInfo } from "$models/Game";
import { useAccount } from "wagmi";

type Props = {
  games: GameInfo[] | undefined;
};

const GameDisplay: React.FC<Props> = ({ games }) => {
  const { address } = useAccount();
  function selectGame(game: GameInfo) {}

  return (
    <>
      {address &&
        games &&
        games
          .filter((info) => info.players.includes(address))
          .map((info) => {
            return (
              <div className="game" key={info.id}>
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
                <IonButton
                  // className="rectangle-button"
                  fill="clear"
                  onClick={() => selectGame(info)}
                >
                  <IonLabel>Join</IonLabel>
                </IonButton>
              </div>
            );
          })}
    </>
  );
};

export default memo(GameDisplay);
