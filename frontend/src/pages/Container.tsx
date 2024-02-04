import {
  IonButton,
  IonContent,
  IonHeader,
  IonIcon,
  IonLabel,
  IonMenu,
  IonMenuToggle,
  IonPage,
  IonRouterOutlet,
  IonSplitPane,
  IonTabBar,
  IonTabButton,
  IonTabs,
  IonTitle,
  IonToolbar,
} from "@ionic/react";
import { Redirect, Route } from "react-router";
import { extensionPuzzleSharp, homeSharp, walletSharp } from "ionicons/icons";
import { memo } from "react";

import HomePage from "./home/Home";
import PlayPage from "./play/Play";
import MatchesPage from "./matches/Matches";
import OffersPage from "./offers/Offers";

import "./Container.scss";
import LeftMenu from "$ui/LeftMenu/LeftMenu";
import RightMenu from "$ui/RightMenu/RightMenu";
import { useMenuContext } from "$contexts/MenuContext";
import Tabs from "$ui/Tabs/Tabs";
import Header from "$ui/Header/Header";
import DataFetchers from "./DataFetcher";

const Container: React.FC = () => {
  const version = "0.0.1";
  const { leftMenuOpen, rightMenuOpen } = useMenuContext();

  return (
    <IonPage>
      <Header />
      <IonSplitPane
        id="left-split-pane"
        contentId="main"
        when={true}
        className={leftMenuOpen ? "big " : "small "}
      >
        <LeftMenu />
        <div className="ion-page" id="main">
          <IonSplitPane
            id="right-split-pane"
            contentId="second"
            when={true}
            className={rightMenuOpen ? "big" : "small"}
          >
            <div className="ion-page" id="second">
              <DataFetchers />
              <Tabs
                home={<HomePage />}
                play={<PlayPage />}
                matches={<MatchesPage />}
                offers={<OffersPage />}
              />
            </div>
            <RightMenu />
          </IonSplitPane>
        </div>
      </IonSplitPane>
    </IonPage>
  );
};

export default memo(Container);
