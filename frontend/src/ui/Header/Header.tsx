import { IonHeader, IonToolbar } from "@ionic/react";
import { memo } from "react";

import "./Header.scss";
import GameSelector from "./GameSelector/GameSelector";

const Header: React.FC = () => {
  const version = "0.0.1";
  return (
    <IonHeader>
      <IonToolbar>
        <div id="toolbar">
          <div className="logo">
            <div id="logo-text">
              <span>Eth</span>poir
            </div>
            <div id="version" className="hide-md">
              {version}
            </div>
          </div>
          <GameSelector />
        </div>
      </IonToolbar>
    </IonHeader>
  );
};

export default memo(Header);
