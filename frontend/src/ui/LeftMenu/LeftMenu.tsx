import {
  IonButton,
  IonContent,
  IonIcon,
  IonLabel,
  IonMenu,
} from "@ionic/react";
import { memo } from "react";

import "./LeftMenu.scss";
import { caretBackSharp, caretForwardSharp } from "ionicons/icons";
import PlayerAccount from "./PlayerAccount/PlayerAccount";
import { useMenuContext } from "$contexts/MenuContext";
import PlayerHand from "./PlayerHand/PlayerHand";
import MatchesHistory from "./MatchesHistory/MatchesHistory";

const LeftMenu: React.FC = () => {
  const { leftMenuOpen, toggleLeftSide } = useMenuContext();

  return (
    <IonMenu side="start" menuId="left-side" contentId="main">
      <IonContent id="left-side-menu-content">
        <div className="menu-container">
          <div className={`big-section ${leftMenuOpen ? "" : "closed"}`}>
            <PlayerAccount />
            <MatchesHistory />
          </div>
          <div className="small-section">
            <IonButton
              slot="icon-only"
              fill="clear"
              color="primary"
              expand="full"
              onClick={() => toggleLeftSide()}
            >
              <IonIcon
                icon={leftMenuOpen ? caretBackSharp : caretForwardSharp}
              />
            </IonButton>
            <PlayerHand />
          </div>
        </div>
      </IonContent>
    </IonMenu>
  );
};

export default memo(LeftMenu);
