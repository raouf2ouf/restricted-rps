import { IonIcon } from "@ionic/react";
import { memo, useMemo, useState } from "react";

import "./StarSelector.scss";

interface Prop {
  max: number;
  onSelect: (nbrStars: number) => void;
}

const StarSelector: React.FC<Prop> = ({ max, onSelect }) => {
  const [nbr, setNbr] = useState<number>(0);

  function handleSelect(nbrStars: number) {
    if (nbrStars > max) return;
    if (nbr == nbrStars) {
      nbrStars--;
    }
    setNbr(nbrStars);
    onSelect(nbrStars);
  }

  return (
    <div className="star-selector-container">
      <div className="star-selector-background">
        {[...Array(5)].map((i, idx) => {
          return (
            <IonIcon
              key={idx}
              onClick={() => handleSelect(idx + 1)}
              className={`${idx + 1 > max ? "above-max" : ""}`}
              icon={`/assets/${nbr > idx ? "star" : "star_slot"}.svg`}
            />
          );
        })}
        {/* <IonIcon icon={`/assets/${nbr > 1 ? "star" : "star_slot"}.svg`} />
        <IonIcon icon={`/assets/${nbr > 2 ? "star" : "star_slot"}.svg`} />
        <IonIcon icon={`/assets/${nbr > 3 ? "star" : "star_slot"}.svg`} />
        <IonIcon icon={`/assets/${nbr > 4 ? "star" : "star_slot"}.svg`} /> */}
      </div>
    </div>
  );
};

export default memo(StarSelector);
