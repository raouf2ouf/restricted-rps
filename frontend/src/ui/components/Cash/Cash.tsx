import { IonIcon } from "@ionic/react";
import { memo } from "react";

import "./Cash.scss";

interface Prop {
  amount: number;
}

const Cash: React.FC<Prop> = ({ amount }) => {
  return (
    <div className="cash-container">
      <div className="cash-background">
        {/* <IonIcon icon="/assets/coins.svg" /> */}
        <div className="amount">{amount}k</div>
      </div>
    </div>
  );
};

export default memo(Cash);
