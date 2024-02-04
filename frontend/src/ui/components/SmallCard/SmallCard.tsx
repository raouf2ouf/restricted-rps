import { IonIcon } from "@ionic/react";
import { memo, useMemo } from "react";

import "./SmallCard.scss";
import { Card, cardToType } from "$models/Card";

interface Prop {
  card: Card;
  nbr?: number | string;
  bg?: boolean;
  nbrLocked?: number;
}

const SmallCard: React.FC<Prop> = ({ card, nbr, bg, nbrLocked }) => {
  const type = useMemo(() => cardToType(card), [card]);

  return (
    <div className="small-card-container">
      <div className={`${type} ${bg ? "bg" : ""}`}>
        <IonIcon icon={`/assets/${type}.svg`} />
        <div className="number">
          {typeof nbr == "number" ? nbr - (nbrLocked || 0) : nbrLocked || 0}/
          {nbr}
        </div>
      </div>
    </div>
  );
};

export default memo(SmallCard);
