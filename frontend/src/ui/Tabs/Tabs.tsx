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

type Props = {
  home: ReactNode;
  play: ReactNode;
  matches: ReactNode;
  offers: ReactNode;
  history: ReactNode;
};

const Tabs: React.FC<Props> = ({ home, play, matches, offers, history }) => {
  return (
    <IonTabs>
      <IonRouterOutlet>
        <Redirect exact path="/" to="/home" />
        <Route path="/home" render={() => home} />
        <Route path="/play" render={() => play} />
        <Route path="/matches" render={() => matches} />
        {/* <Route path="/offers" render={() => offers} /> */}
        <Route path="/history" render={() => history} />
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
