import { IonIcon } from "@ionic/react";
import { memo, useMemo } from "react";

import "./SmallCard.scss";
import { Card, cardToType } from "$models/Card";

interface Prop {
  card: Card;
  nbr?: number | string;
  bg?: boolean;
  nbrLocked?: number;
  simple?: boolean;
}

const SmallCard: React.FC<Prop> = ({ card, nbr, bg, nbrLocked, simple }) => {
  const type = useMemo(() => cardToType(card), [card]);

  return (
    <div className="small-card-container">
      <div className={`${type} ${bg ? "bg" : ""}`}>
        <IonIcon icon={`/assets/${type}.svg`} />
        {!simple && (
          <div className="number">
            {typeof nbr == "number" ? nbr - (nbrLocked || 0) : nbrLocked || 0}/
            {nbr}
          </div>
        )}
      </div>
    </div>
  );
};

export default memo(SmallCard);
