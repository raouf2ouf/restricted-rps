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
import { selectMatchesForGame } from "$store/matches.slice";
import MatchDisplay from "./MatchDisplay";
import OfferMatchModal from "./OfferMatchModal";
import { Match, MatchState } from "$models/Match";

const MatchesPage: React.FC = () => {
  const [playerOpenMatches, setPlayerOpenMatches] = useState<Match[]>([]);
  const [otherOpenMatches, setOtherOpenMatches] = useState<Match[]>([]);
  const { currentGameAddress, currentPlayerId } = useCurrentGameContext();

  const [present, dismiss] = useIonModal(OfferMatchModal, {
    onDismiss: (data: string, role: string) => dismiss(data, role),
  });

  const matches = useAppSelector((state) =>
    selectMatchesForGame(state, currentGameAddress || "")
  );

  useEffect(() => {
    setPlayerOpenMatches(
      matches.filter((m) => {
        console.log("matchplayer", m.player1);
        console.log("currentplayerId", currentPlayerId);
        return m.player1 == currentPlayerId && m.result == MatchState.UNDECIDED;
      })
    );
    setOtherOpenMatches(
      matches.filter(
        (m) => m.player1 != currentPlayerId && m.result == MatchState.UNDECIDED
      )
    );
  }, [matches, currentPlayerId]);

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
                  <MatchDisplay id={m.id} key={m.id} isPlayer />
                ))}
                <IonButton
                  className="rectangle-button"
                  fill="clear"
                  onClick={offerMatch}
                >
                  <IonLabel>Offer a Match</IonLabel>
                </IonButton>
              </div>
              <div className="section other-player-matches">
                <IonLabel>
                  <div>Other Player's Open Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {otherOpenMatches.map((m) => (
                  <MatchDisplay id={m.id} key={m.id} />
                ))}
              </div>
              <div className="section played-matches">
                <IonLabel>
                  <div>Played Matches</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
              </div>
            </>
          )}
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(MatchesPage);
