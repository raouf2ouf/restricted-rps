import { memo } from "react";

import "./PlayerAccount.scss";
import { IonLabel } from "@ionic/react";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import GainsChart from "./GainsChart";
import Wallet from "./Wallet";
import WinLossRatio from "./WinLossRatio";
type Props = {};

const PlayerAccount: React.FC<Props> = ({}) => {
  return (
    <div className="section player">
      <IonLabel>
        <div>Current Player</div>
        <Tooltip text=""></Tooltip>
      </IonLabel>
      <Wallet />
      <WinLossRatio won={4} draw={2} lost={7} />
      <GainsChart />
    </div>
  );
};

export default memo(PlayerAccount);
