import { EChartsOption } from "echarts";
import { memo, useEffect, useState } from "react";
import { GainsChartOption } from "./GainsChart.option";
import { IonBackdrop, IonSpinner } from "@ionic/react";

import "./GainsChart.scss";
import Chart from "$ui/components/Chart/Chart";
interface Props {}

const DATA: any[] = [];

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
