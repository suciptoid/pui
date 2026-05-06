import ChartHook from "./chart_hook";

export default class ComposeChartHook extends ChartHook {
  readPayload() {
    let payload = {};

    try {
      payload = JSON.parse(this.el.dataset.chartConfig || "{}");
    } catch {
      payload = {};
    }

    const children = this.collectChildConfigs();
    const hasChildren =
      children.bars.length ||
      children.lines.length ||
      children.tooltip ||
      children.legend ||
      children.xAxis ||
      children.yAxis;

    if (hasChildren) {
      return this.mergeChildConfigs(payload, children);
    }

    return payload;
  }

  collectChildConfigs() {
    const children = this.el.querySelectorAll("[data-chart-child]");
    const result = {
      bars: [],
      lines: [],
      tooltip: null,
      legend: null,
      xAxis: null,
      yAxis: null,
    };

    children.forEach((el) => {
      const type = el.dataset.chartChild;
      let config = {};

      try {
        config = JSON.parse(el.dataset.chartConfig || "{}");
      } catch {
        config = {};
      }

      switch (type) {
        case "bar":
          result.bars.push(config);
          break;
        case "line":
          result.lines.push(config);
          break;
        case "tooltip":
          result.tooltip = config;
          break;
        case "legend":
          result.legend = config;
          break;
        case "x-axis":
          result.xAxis = config;
          break;
        case "y-axis":
          result.yAxis = config;
          break;
      }
    });

    return result;
  }

  mergeChildConfigs(payload, children) {
    const merged = { ...payload };

    if (!merged.preset) {
      if (children.bars.length) merged.preset = "bar";
      else if (children.lines.length) merged.preset = "line";
    }

    if (children.xAxis) {
      if (children.xAxis.categories?.length)
        merged.categories = children.xAxis.categories;
      if (children.xAxis.labels?.length)
        merged.labels = children.xAxis.labels;
      if (children.xAxis.time) merged.time = children.xAxis.time;
    }

    const childSeriesData = [];
    const childSeriesConfig = [];

    children.bars.forEach((bar) => {
      if (bar.series_data) childSeriesData.push(...bar.series_data);
      if (bar.series) childSeriesConfig.push(...bar.series);
      if (bar.bar_width != null || bar.max_bar_width != null) {
        merged.bar = {
          size: [bar.bar_width ?? 0.72, bar.max_bar_width ?? 64],
        };
      }
    });

    children.lines.forEach((line) => {
      if (line.series_data) childSeriesData.push(...line.series_data);
      if (line.series) childSeriesConfig.push(...line.series);
      if (line.curve) merged.curve = line.curve;
      if (line.area) merged.area = line.area;
      if (line.time) merged.time = line.time;
      if (line.labels?.length) merged.labels = line.labels;
      if (line.x) merged.x = line.x;
    });

    if (childSeriesData.length > 0) {
      const seriesLength = childSeriesData[0]?.length || 0;
      let xValues;

      if (merged.x) {
        xValues = merged.x;
      } else {
        xValues = Array.from({ length: seriesLength }, (_, i) => i);
      }

      merged.data = [xValues, ...childSeriesData];
      merged.series = childSeriesConfig;
    }

    if (children.tooltip) {
      merged.tooltip = { ...(merged.tooltip || {}), ...children.tooltip };
    }

    if (children.legend) {
      merged.legend = { ...(merged.legend || {}), ...children.legend };
    }

    return merged;
  }
}
