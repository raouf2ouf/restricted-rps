import {
  IonIcon,
  IonLabel,
  IonRouterOutlet,
  IonTabBar,
  IonTabButton,
  IonTabs,
} from "@ionic/react";
import {
  extensionPuzzleSharp,
  homeSharp,
  statsChartSharp,
  walletSharp,
} from "ionicons/icons";
import { ReactNode, memo } from "react";
import { Redirect, Route } from "react-router";
import History from "src/pages/history/History";
import Home from "src/pages/home/Home";
import Matches from "src/pages/matches/Matches";
import Play from "src/pages/play/Play";

type Props = {};

const Tabs: React.FC<Props> = ({}) => {
  return (
    <IonTabs>
      <IonRouterOutlet>
        <Redirect exact path="/" to="/home" />
        <Route path="/home" render={() => <Home />} />
        <Route path="/play" render={() => <Play />} />
        <Route path="/matches" render={() => <Matches />} />
        {/* <Route path="/offers" render={() => offers} /> */}
        <Route path="/history" render={() => <History />} />
      </IonRouterOutlet>
      <IonTabBar slot="bottom">
        <IonTabButton tab="home" href="/home">
          <IonIcon icon={homeSharp} />
          <IonLabel>Home</IonLabel>
        </IonTabButton>
        <IonTabButton tab="play" href="/play">
          <IonIcon icon={homeSharp} />
          <IonLabel>Play</IonLabel>
        </IonTabButton>
        <IonTabButton tab="matches" href="/matches">
          <IonIcon icon={extensionPuzzleSharp} />
          <IonLabel>Matches</IonLabel>
        </IonTabButton>
        {/* <IonTabButton tab="offers" href="/offers" disabled>
        <IonIcon icon={walletSharp} />
        <IonLabel>Offers</IonLabel>
      </IonTabButton> */}
        <IonTabButton tab="history" href="/history">
          <IonIcon icon={statsChartSharp} />
          <IonLabel>History</IonLabel>
        </IonTabButton>
      </IonTabBar>
    </IonTabs>
  );
};

export default memo(Tabs);
