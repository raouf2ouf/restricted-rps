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
import OfferMatchModal from "./OfferMatchModal";
import { Match, MatchState } from "$models/Match";
import OpenMatchDisplay from "./OpenMatchDisplay";
import AnsweredMatchDisplay from "./AnsweredMatchDisplay";

const MatchesPage: React.FC = () => {
  const [playerOpenMatches, setPlayerOpenMatches] = useState<Match[]>([]);
  const [otherOpenMatches, setOtherOpenMatches] = useState<Match[]>([]);
  const [toCloseMatches, settoCloseMatches] = useState<Match[]>([]);
  const [otherMatches, setOtherMatches] = useState<Match[]>([]);
  const { currentGameAddress, currentPlayerId } = useCurrentGameContext();

  const [present, dismiss] = useIonModal(OfferMatchModal, {
    onDismiss: (data: string, role: string) => dismiss(data, role),
  });

  const matches = useAppSelector((state) =>
    selectMatchesForGame(state, currentGameAddress || "")
  );

  useEffect(() => {
    const playerOpen: Match[] = [];
    const otherOpen: Match[] = [];
    const toClose: Match[] = [];
    const other: Match[] = [];
    for (const m of matches) {
      if (m.player1 == currentPlayerId) {
        if (m.result == MatchState.UNDECIDED) {
          playerOpen.push(m);
        } else if (m.result == MatchState.ANSWERED) {
          toClose.push(m);
        } else if (m.result != MatchState.CANCELLED) {
          other.push(m);
        }
      } else if (m.result == MatchState.UNDECIDED) {
        otherOpen.push(m);
      } else {
        if (m.result != MatchState.CANCELLED) {
          other.push(m);
        }
      }
    }
    setPlayerOpenMatches(playerOpen);
    setOtherOpenMatches(otherOpen);
    settoCloseMatches(toClose);
    setOtherMatches(other);
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
                {otherMatches.map((m) => (
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
