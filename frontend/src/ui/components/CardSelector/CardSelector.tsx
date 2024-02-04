import { IonIcon } from "@ionic/react";
import { memo, useMemo, useState } from "react";

import "./CardSelector.scss";
import { Card } from "$models/Card";

interface Prop {
  nbrRocks?: number;
  nbrPapers?: number;
  nbrScissors?: number;
  onSelect: (card: Card) => void;
}

const CardSelector: React.FC<Prop> = ({
  nbrRocks,
  nbrPapers,
  nbrScissors,
  onSelect,
}) => {
  const [card, setCard] = useState<Card | undefined>(undefined);

  function handleSubmit(c: Card) {
    if (c == Card.ROCK && nbrRocks == 0) return;
    if (c == Card.PAPER && nbrPapers == 0) return;
    if (c == Card.SCISSORS && nbrScissors == 0) return;
    setCard(c);
    onSelect(c);
  }

  return (
    <div className="card-selector-container">
      <div
        className={`rock  ${card === Card.ROCK ? "selected" : ""}`}
        onClick={() => handleSubmit(Card.ROCK)}
      >
        <IonIcon
          icon={`/assets/rock.svg`}
          className={`${nbrRocks == 0 ? "empty" : ""}`}
        />
        <div className="number">{nbrRocks}</div>
      </div>
      <div
        className={`paper ${card === Card.PAPER ? "selected" : ""}`}
        onClick={() => handleSubmit(Card.PAPER)}
      >
        <IonIcon
          icon={`/assets/paper.svg`}
          className={`${nbrPapers == 0 ? "empty" : ""} `}
        />
        <div className="number">{nbrPapers}</div>
      </div>
      <div
        className={`scissors ${card === Card.SCISSORS ? "selected" : ""}`}
        onClick={() => handleSubmit(Card.SCISSORS)}
      >
        <IonIcon
          icon={`/assets/scissors.svg`}
          className={`${nbrScissors == 0 ? "empty" : ""}`}
        />
        <div className="number">{nbrScissors}</div>
      </div>
    </div>
  );
};

export default memo(CardSelector);
