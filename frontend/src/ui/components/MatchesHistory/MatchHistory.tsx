import { memo } from "react";

import "./MatchHistory.scss";
import { IonIcon, IonLabel } from "@ionic/react";

type Props = {};

const MatcheHistory: React.FC<Props> = ({}) => {
  return (
    <div className="match-history-container">
      <div className="game-info">
        <div className="game-offer">
          <IonLabel className="label">Against: </IonLabel>
          <IonLabel>0x9b5...d18</IonLabel>
        </div>
        <div className="game-id-container">
          <IonLabel className="label">Game Id: </IonLabel>
          <IonLabel className="game-id">1</IonLabel>
        </div>
      </div>
      <div className="game-details">
        <IonIcon className="paper" icon="./assets/paper.svg" />
        <IonLabel>X</IonLabel>
        <IonIcon className="rock" icon="./assets/rock.svg" />
        <IonLabel>=</IonLabel>
        <IonLabel className="game-status won">Won</IonLabel>
      </div>
    </div>
  );
};

export default memo(MatcheHistory);
