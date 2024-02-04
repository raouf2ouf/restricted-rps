import { useRef, useEffect, memo } from "react";
import { init, getInstanceByDom } from "echarts";
import type { CSSProperties } from "react";
import type { EChartsOption, ECharts, SetOptionOpts } from "echarts";
import { useTimeout } from "$hooks/useTimeout";

type Props = {
  option: EChartsOption;
  style?: CSSProperties;
  settings?: SetOptionOpts;
};

const Chart: React.FC<Props> = ({ option, style, settings }) => {
  const chartRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Initialize chart
    let chart: ECharts | undefined;
    if (chartRef.current !== null) {
      chart = init(chartRef.current);
    }

    // Add chart resize listener
    // ResizeObserver is leading to a bit janky UX
    function resizeChart() {
      chart?.resize();
    }
    window.addEventListener("resize", resizeChart);

    // Return cleanup function
    return () => {
      chart?.dispose();
      window.removeEventListener("resize", resizeChart);
    };
  }, []);

  useEffect(() => {
    // Update chart
    if (chartRef.current !== null) {
      const chart = getInstanceByDom(chartRef.current)!;
      chart.setOption(option, settings);
      chart.resize();
    }
  }, [option, settings]); // Whenever theme changes we need to add option and setting due to it being deleted in cleanup function

  useTimeout(() => {
    if (chartRef.current !== null) {
      const chart = getInstanceByDom(chartRef.current)!;
      chart.resize();
    }
  }, 300);

  return (
    <div ref={chartRef} style={{ width: "100%", height: "200px", ...style }} />
  );
};

export default memo(Chart);
