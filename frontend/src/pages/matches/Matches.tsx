import {
  IonButton,
  IonContent,
  IonLabel,
  IonPage,
  useIonModal,
} from "@ionic/react";
import { memo, useEffect, useState } from "react";

import "./Matches.scss";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import { useAppSelector } from "$store/store";
import {
  selectAnsweredMatchesForGameOfPlayer,
  selectMatchesForGame,
  selectOpenMatchesForGameOfNotPlayer,
  selectOpenMatchesForGameOfPlayer,
  selectPlayedMatchesForGame,
} from "$store/matches.slice";
import OfferMatchModal from "./OfferMatchModal";
import { MatchState } from "$models/Match";
import OpenMatchDisplay from "./OpenMatchDisplay";
import AnsweredMatchDisplay from "./AnsweredMatchDisplay";

const MatchesPage: React.FC = () => {
  const { currentGameAddress, currentPlayerId } = useCurrentGameContext();

  const [present, dismiss] = useIonModal(OfferMatchModal, {
    onDismiss: (data: string, role: string) => dismiss(data, role),
  });

  const playerOpenMatches = useAppSelector((state) =>
    selectOpenMatchesForGameOfPlayer(
      state,
      currentGameAddress || "",
      currentPlayerId
    )
  );
  const toCloseMatches = useAppSelector((state) =>
    selectAnsweredMatchesForGameOfPlayer(
      state,
      currentGameAddress || "",
      currentPlayerId
    )
  );
  const otherOpenMatches = useAppSelector((state) =>
    selectOpenMatchesForGameOfNotPlayer(
      state,
      currentGameAddress || "",
      currentPlayerId
    )
  );
  const playedMatches = useAppSelector((state) =>
    selectPlayedMatchesForGame(state, currentGameAddress || "")
  );

  function offerMatch() {
    present();
  }

  return (
    <IonPage>
      <IonContent>
        <div className="matches-main-container">
          {!currentGameAddress ? (
            <div className="section">
              <IonLabel>Please, select a Game to check Matches</IonLabel>
            </div>
          ) : (
            <>
              <div className="section player-matches">
                <IonLabel>
                  <div>Your Current Open Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {playerOpenMatches.map((m) => (
                  <OpenMatchDisplay id={m.id} key={m.id} isPlayer />
                ))}
                <IonButton
                  className="rectangle-button"
                  fill="clear"
                  onClick={offerMatch}
                >
                  <IonLabel>Offer a Match</IonLabel>
                </IonButton>
              </div>
              <div className="section to-close-matches">
                <IonLabel>
                  <div>Your Answered Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {toCloseMatches.map((m) => (
                  <AnsweredMatchDisplay id={m.id} key={m.id} isPlayer />
                ))}
              </div>
              <div className="section other-player-matches">
                <IonLabel>
                  <div>Other Player's Open Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {otherOpenMatches.map((m) => (
                  <OpenMatchDisplay id={m.id} key={m.id} />
                ))}
              </div>
              <div className="section played-matches">
                <IonLabel>
                  <div>Played Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {playedMatches.map((m) => (
                  <AnsweredMatchDisplay id={m.id} key={m.id} />
                ))}
              </div>
            </>
          )}
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(MatchesPage);
