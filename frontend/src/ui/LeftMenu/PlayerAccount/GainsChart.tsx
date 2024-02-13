import { EChartsOption } from "echarts";
import { memo, useEffect, useState } from "react";
import { GainsChartOption } from "./GainsChart.option";
import { IonBackdrop, IonSpinner } from "@ionic/react";

import "./GainsChart.scss";
import Chart from "$ui/components/Chart/Chart";
import { History } from "$models/History";
import { wTe } from "$contracts/index";
import { getHistory } from "src/api/server";
import { useAccount } from "wagmi";
import { useAppSelector } from "$store/store";
import { selectAllHistories } from "$store/histories.slice";
interface Props {}

function buildData(histories: History[]): number[][] {
  const data: number[][] = [];
  for (let i = 0; i < histories.length; i++) {
    const history = histories[i];
    const n = wTe(BigInt(history.rewards) - BigInt(history.paidAmount));
    data.push([i, n]);
  }
  return data;
}

const GainsChart: React.FC<Props> = ({}) => {
  const { address } = useAccount();

  const loading: boolean = false;
  const [option, setOption] = useState<EChartsOption>(GainsChartOption);
  const history = useAppSelector((state) => selectAllHistories(state));

  useEffect(() => {
    if (history.length == 0) return;
    let op: EChartsOption = { ...GainsChartOption };
    const data = buildData(history);
    //@ts-ignore
    op.series[0].data = data;
    setOption({ ...op });
  }, [history]);

  return (
    <div className="gains-chart-container">
      {loading && (
        <div className="gains-chart-loading">
          <IonSpinner name="lines-sharp" color="primary"></IonSpinner>
          <IonBackdrop visible={true} tappable={false}></IonBackdrop>
        </div>
      )}
      <Chart
        option={option}
        style={{ width: "290px", minHeight: "200px" }}
      ></Chart>
    </div>
  );
};

export default memo(GainsChart);
