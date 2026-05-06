import ChartHook from "./chart_hook";

export default class SparklineChart extends ChartHook {
  measureSize(payload) {
    const width = Math.max(
      Math.round(this.root?.clientWidth || this.el.clientWidth || 0),
      48,
    );

    return {
      width,
      height: payload.height || 56,
    };
  }

  buildOptions(payload, size) {
    const options = super.buildOptions(
      {
        ...payload,
        preset: "line",
        grid: false,
        tooltip: { ...payload.tooltip, show: false },
        legend: { ...payload.legend, show: false, live: false },
      },
      size,
    );

    return {
      ...options,
      padding: [4, 2, 4, 2],
      cursor: { show: false },
      select: { show: false },
      legend: { show: false },
      axes: [{ show: false }, { show: false }],
      series: options.series.map((series, index) => {
        if (index === 0) {
          return series;
        }

        return {
          ...series,
          width: payload.series[index - 1]?.width ?? 1.5,
          points: { show: false },
          fill:
            payload.series[index - 1]?.fill || this.withAlpha(series.stroke, 0.18),
          paths: this.uPlot.paths.linear(),
        };
      }),
    };
  }
}
