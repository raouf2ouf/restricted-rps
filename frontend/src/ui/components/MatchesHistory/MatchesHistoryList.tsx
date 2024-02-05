import { memo } from "react";

import "./MatchesHistoryList.scss";
import MatchHistory from "./MatchHistory";
import { Match, MatchState } from "$models/Match";

type Props = {
  matches: Match[];
  playerId: number;
};

const MatchesHistoryList: React.FC<Props> = ({ matches, playerId }) => {
  return (
    <div className="matches-history-list-container">
      <div className="matches">
        {matches
          .filter(
            (m) =>
              (m.player1 == playerId || m.player2 == playerId) &&
              m.result != MatchState.UNDECIDED &&
              m.result != MatchState.ANSWERED
          )
          .map((m) => {
            return (
              <MatchHistory key={m.matchId} match={m} playerId={playerId} />
            );
          })}
      </div>
    </div>
  );
};

export default memo(MatchesHistoryList);
