import List from "$ui/components/List/List";
import { memo } from "react";

import "./MatchesHistory.scss";
import { IonLabel } from "@ionic/react";
import Tooltip from "$ui/components/Tooltip/Tooltip";
type Props = {};

const MatchesHistory: React.FC<Props> = ({}) => {
  return (
    <div className="section matches-history">
      <IonLabel>
        <div>Matches History</div>
        <Tooltip text=""></Tooltip>
      </IonLabel>

      <List>
        <div></div>
      </List>
    </div>
  );
};

export default memo(MatchesHistory);
