import { memo } from "react";

import "./MatchesHistoryList.scss";
import MatchHistory from "./MatchHistory";

type Props = {};

const MatchesHistoryList: React.FC<Props> = ({}) => {
  return (
    <div className="matches-history-list-container">
      <div className="matches">
        <MatchHistory />
        <MatchHistory />
        <MatchHistory />
        <MatchHistory />
      </div>
    </div>
  );
};

export default memo(MatchesHistoryList);
