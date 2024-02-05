import { EChartsOption } from "echarts";
import { memo, useEffect, useState } from "react";
import { GainsChartOption } from "./GainsChart.option";
import { IonBackdrop, IonSpinner } from "@ionic/react";

import "./GainsChart.scss";
import Chart from "$ui/components/Chart/Chart";
interface Props {}

function getRandom(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}

function generateData(nbr: number): number[][] {
  const data: number[][] = [];
  let previous: number = 0;
  for (let i = 0; i < nbr; i++) {
    previous += getRandom(-0.08, +0.09);
    if (previous > 1) {
      previous = 0.94;
    }
    data.push([i, previous]);
  }
  return data;
}
const DATA = generateData(11);

const GainsChart: React.FC<Props> = ({}) => {
  const data = DATA;

  const loading: boolean = false;
  const [option, setOption] = useState<EChartsOption>(GainsChartOption);

  useEffect(() => {
    let op: EChartsOption = { ...GainsChartOption };
    //@ts-ignore
    op.series[0].data = data;
    setOption({ ...op });
  }, [data]);

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
