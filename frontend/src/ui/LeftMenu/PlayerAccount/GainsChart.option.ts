import { EChartsOption } from "echarts";

export const GainsChartOption: EChartsOption = {
  xAxis: {
    type: "category",
    axisTick: {
      show: true,
      alignWithLabel: true,
    },
    axisLabel: {
      show: true,
      inside: true,
      fontSize: 8,
      verticalAlign: "top",
      margin: 90,
    },
  },
  yAxis: {
    show: true,
    name: "Gains (ETH)",
    nameTextStyle: {
      fontSize: 12,
      fontFamily: "Titillium Web",
    },
    nameRotate: 90,
    nameLocation: "middle",
    type: "value",
    position: "left",
    min: -1,
    max: 1,
    splitLine: {
      show: false,
    },
    axisLabel: {
      show: true,
      fontSize: 8,
      verticalAlign: "middle",
      margin: 2,
    },
  },
  grid: [{ bottom: 10, top: 10, right: 0 }],
  visualMap: {
    show: false,
    dimension: 1,
    pieces: [
      {
        lte: 0,
        gte: -1,
        color: "#cf3c4f",
      },
      {
        gte: 0,
        lte: 1,
        color: "#0ac1dd",
      },
    ],
  },
  series: [
    {
      name: "Gains",
      type: "line",
      smooth: true,
      symbol: "circle",
      markArea: {
        silent: true,
        label: {
          position: "left",
          color: "rgba(215, 216, 218, 0.8)",
          rotate: 90,
          offset: [15, -5],
          fontSize: 14,
          fontFamily: "Titillium Web",
        },
        itemStyle: { color: "rgba(11, 219, 251, 0.1)" },
        data: [[{ name: "", yAxis: 0 }, { yAxis: 20 }]],
      },
    },
    {
      name: "Prediction",
      type: "line",
      smooth: true,
      symbol: "none",
      markArea: {
        silent: true,
        label: {
          position: "left",
          color: "rgba(215, 216, 218, 0.8)",
          rotate: 90,
          offset: [30, -5],
          fontSize: 14,
          fontFamily: "Titillium Web",
        },
        itemStyle: { color: "rgba(9, 20, 36, 0.2)" },
        data: [[{ name: "", yAxis: -20 }, { yAxis: -0 }]],
      },
    },
  ],
};
