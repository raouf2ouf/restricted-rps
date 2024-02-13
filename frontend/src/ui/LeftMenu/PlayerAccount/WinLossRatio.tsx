import { memo, useEffect, useState } from "react";

import "./WinLossRatio.scss";
import { useAppSelector } from "$store/store";
import { selectAllHistories } from "$store/histories.slice";

interface Props {}

const WinLossRation: React.FC<Props> = () => {
  const histories = useAppSelector((state) => selectAllHistories(state));
  const [wonPercent, setWonPercent] = useState<number>(0);
  const [drawPercent, setDrawPercent] = useState<number>(0);
  const [lostPercent, setLostPercent] = useState<number>(0);
  const [won, setWon] = useState<number>(0);
  const [draw, setDraw] = useState<number>(0);
  const [lost, setLost] = useState<number>(0);

  useEffect(() => {
    const total = histories.length;
    let won = 0,
      draw = 0,
      lost = 0;
    for (const history of histories) {
      const paidAmount = BigInt(history.paidAmount);
      const rewards = BigInt(history.rewards);
      if (paidAmount > rewards) {
        lost++;
      } else if (paidAmount < rewards) {
        won++;
      } else {
        draw++;
      }
    }
    if (total > 0) {
      setWonPercent((won * 100) / total);
      setDrawPercent((draw * 100) / total);
      setLostPercent((lost * 100) / total);
    } else {
      setWonPercent(0);
      setDrawPercent(0);
      setLostPercent(0);
    }
    setWon(won);
    setLost(lost);
    setDraw(draw);
  }, [histories]);

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
        <div className="nbr-won">{wonPercent.toFixed(2)}% Won</div>
        <div className="nbr-draw">{drawPercent.toFixed(2)}% Draw</div>
        <div className="nbr-lost">{lostPercent.toFixed(2)}% Lost</div>
      </div>
    </div>
  );
};

export default memo(WinLossRation);
