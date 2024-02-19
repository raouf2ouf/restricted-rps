import { IonPage, IonSplitPane } from "@ionic/react";
import HomePage from "./home/Home";
import PlayPage from "./play/Play";
import MatchesPage from "./matches/Matches";
import OffersPage from "./offers/Offers";
import HistoryPage from "./history/History";
import LeftMenu from "$ui/LeftMenu/LeftMenu";
import RightMenu from "$ui/RightMenu/RightMenu";
import { useMenuContext } from "$contexts/MenuContext";
import Tabs from "$ui/Tabs/Tabs";
import Header from "$ui/Header/Header";
import DataFetchers from "./DataFetcher";
import { memo } from "react";
import "./Container.scss";

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
        <div id="main">
          <IonSplitPane
            id="right-split-pane"
            contentId="second"
            when={true}
            className={rightMenuOpen ? "big" : "small"}
          >
            <div id="second">
              <DataFetchers />
              <Tabs
              // home={<HomePage />}
              // play={<PlayPage />}
              // matches={<MatchesPage />}
              // offers={<OffersPage />}
              // history={<HistoryPage />}
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
