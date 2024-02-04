import { IonButton, IonContent, IonIcon, IonMenu } from "@ionic/react";
import { memo } from "react";

import "./RightMenu.scss";
import { caretBackSharp, caretForwardSharp } from "ionicons/icons";
import { useMenuContext } from "$contexts/MenuContext";
import GameState from "./GameState/GameState";
import EventsHistory from "./EventsHistory/EventsHistory";

const RightMenu: React.FC = () => {
  const { rightMenuOpen, toggleRightSide } = useMenuContext();

  return (
    <IonMenu side="end" menuId="right-side" contentId="main">
      <IonContent id="right-side-menu-content">
        <div className="menu-container">
          <div className="small-section">
            <IonButton
              slot="icon-only"
              fill="clear"
              color="primary"
              expand="full"
              onClick={() => toggleRightSide()}
            >
              <IonIcon
                icon={rightMenuOpen ? caretForwardSharp : caretBackSharp}
              />
            </IonButton>
            <GameState />
          </div>
          <div className="big-section">
            <EventsHistory />
          </div>
        </div>
      </IonContent>
    </IonMenu>
  );
};

export default memo(RightMenu);
