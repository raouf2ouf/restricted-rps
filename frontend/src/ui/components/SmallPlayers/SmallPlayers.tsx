import { IonIcon } from "@ionic/react";
import { memo } from "react";

import "./SmallPlayers.scss";
interface Props {
  nbr: number;
}

const SmallPlayers: React.FC<Props> = ({ nbr }) => {
  return (
    <div className="small-players-container">
      <div className="small-players-background">
        <IonIcon icon="/assets/player.svg" />
        <div className="number">{nbr}</div>
      </div>
    </div>
  );
};

export default memo(SmallPlayers);
