import List from "$ui/components/List/List";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import { IonLabel } from "@ionic/react";
import { memo } from "react";

import "./EventsHistory.scss";
type Props = {};

const EventsHistory: React.FC<Props> = ({}) => {
  return (
    <div className="section events-history">
      <IonLabel>
        <div>Game Events</div>
        <Tooltip text=""></Tooltip>
      </IonLabel>

      <List>
        <div></div>
      </List>
    </div>
  );
};

export default memo(EventsHistory);
