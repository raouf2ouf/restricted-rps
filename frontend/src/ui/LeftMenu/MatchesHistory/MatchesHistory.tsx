import List from "$ui/components/List/List";
import { memo } from "react";

import "./MatchesHistory.scss";
import { IonLabel } from "@ionic/react";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import { useAppSelector } from "$store/store";
import { selectMatchesForGame } from "$store/matches.slice";
import MatchHistory from "$ui/components/MatchesHistory/MatchHistory";
import MatchesHistoryList from "$ui/components/MatchesHistory/MatchesHistoryList";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
type Props = {};

const MatchesHistory: React.FC<Props> = ({}) => {
  const { currentGameAddress, currentPlayerId } = useCurrentGameContext();
  const matches = useAppSelector((state) =>
    selectMatchesForGame(state, currentGameAddress || "")
  );

  return (
    <div className="section matches-history">
      <IonLabel>
        <div>Matches History</div>
        <Tooltip text=""></Tooltip>
      </IonLabel>

      {currentPlayerId !== undefined ? (
        <MatchesHistoryList matches={matches} playerId={currentPlayerId} />
      ) : (
        <List>
          <div></div>
        </List>
      )}
    </div>
  );
};

export default memo(MatchesHistory);
