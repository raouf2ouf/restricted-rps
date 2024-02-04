import { memo, useEffect, useState } from "react";

import "./WinLossRatio.scss";

interface Props {
  won: number;
  lost: number;
  draw: number;
}

const WinLossRation: React.FC<Props> = ({ won, lost, draw }) => {
  const [wonPercent, setWonPercent] = useState<number>(0);
  const [drawPercent, setDrawPercent] = useState<number>(0);
  const [lostPercent, setLostPercent] = useState<number>(0);

  useEffect(() => {
    const total = won + lost + draw;
    if (total > 0) {
      setWonPercent((won * 100) / total);
      setDrawPercent((draw * 100) / total);
      setLostPercent((lost * 100) / total);
    } else {
      setWonPercent(0);
      setDrawPercent(0);
      setLostPercent(0);
    }
  }, [won, lost, draw]);

  return (
    <div className="ratio">
      <div className="top-progress-bar">
        <div className="nbr-won">{won}</div>
        <div className="nbr-draw">{draw}</div>
        <div className="nbr-lost">{lost}</div>
      </div>
      <div className="progress-bar-container">
        <div className="won" style={{ width: `${wonPercent}%` }}></div>
        <div className="draw" style={{ width: `${drawPercent}%` }}></div>
        <div className="lost" style={{ width: `${lostPercent}%` }}></div>
      </div>
      <div className="bottom-progress-bar">
        <div className="nbr-won">{wonPercent}% Won</div>
        <div className="nbr-draw">{drawPercent}% Draw</div>
        <div className="nbr-lost">{lostPercent}% Lost</div>
      </div>
    </div>
  );
};

export default memo(WinLossRation);
