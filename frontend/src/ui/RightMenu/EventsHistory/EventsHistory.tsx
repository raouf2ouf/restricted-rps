import List from "$ui/components/List/List";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import { IonLabel } from "@ionic/react";
import { memo } from "react";

import "./EventsHistory.scss";
import { useAppSelector } from "$store/store";
import { selectPlayersStateForGame } from "$store/playersState.slice";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import SmallCard from "$ui/components/SmallCard/SmallCard";
import { Card } from "$models/Card";
import SmallStars from "$ui/components/SmallStars/SmallStars";
type Props = {};

const EventsHistory: React.FC<Props> = ({}) => {
  const { currentGameAddress } = useCurrentGameContext();
  const playerStates = useAppSelector((state) =>
    selectPlayersStateForGame(state, currentGameAddress || "")
  );
  return (
    <div className="section events-history">
      <IonLabel>
        <div>Players States</div>
        <Tooltip text=""></Tooltip>
      </IonLabel>

      <List>
        {playerStates.map((st, i) => {
          return (
            <div className="player-state">
              <div className="game-info">
                <div className="game-offer">
                  <IonLabel className="label">Player </IonLabel>
                  <IonLabel>{st.playerId}</IonLabel>
                </div>
                <div className="game-id-container">
                  <IonLabel className="label">Remaining Cards: </IonLabel>
                  <IonLabel className="game-id">{st.nbrCards}</IonLabel>
                </div>
              </div>
              <div className="game-details">
                <SmallCard
                  nbr={"?"}
                  nbrLocked={st.nbrRockUsed}
                  card={Card.ROCK}
                />
                <SmallCard
                  nbr={"?"}
                  nbrLocked={st.nbrPaperUsed}
                  card={Card.PAPER}
                />
                <SmallCard
                  nbr={"?"}
                  nbrLocked={st.nbrScissorsUsed}
                  card={Card.SCISSORS}
                />
                <SmallStars nbr={st.nbrStars} expanded={3} direction="row" />
              </div>
            </div>
          );
        })}
      </List>
    </div>
  );
};

export default memo(EventsHistory);
