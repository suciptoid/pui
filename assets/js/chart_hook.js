import { ViewHook } from "phoenix_live_view";
import { computePosition, flip, offset, shift } from "@floating-ui/dom";
import uPlot from "uplot";

const DEFAULT_HEIGHT = 320;
const DEFAULT_PALETTE = [
  "--chart-1",
  "--chart-2",
  "--chart-3",
  "--chart-4",
  "--chart-5",
];

const DEFAULT_BAR_SIZE = [0.72, 64];
const SERIES_META_KEYS = new Set([
  "color",
  "curve",
  "data",
  "format",
  "name",
  "prefix",
  "precision",
  "suffix",
  "value_format",
]);

function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function mergeDeep(...values) {
  return values.reduce((acc, value) => mergePair(acc, value), {});
}

function mergePair(left, right) {
  if (!isPlainObject(left)) {
    return cloneValue(right);
  }

  if (!isPlainObject(right)) {
    return cloneValue(right == null ? left : right);
  }

  const merged = { ...left };

  Object.entries(right).forEach(([key, value]) => {
    if (isPlainObject(value) && isPlainObject(merged[key])) {
      merged[key] = mergePair(merged[key], value);
      return;
    }

    merged[key] = cloneValue(value);
  });

  return merged;
}

function cloneValue(value) {
  if (Array.isArray(value)) {
    return value.map((entry) => cloneValue(entry));
  }

  if (isPlainObject(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [key, cloneValue(entry)]),
    );
  }

  return value;
}

function stripSeriesMeta(series) {
  return Object.fromEntries(
    Object.entries(series || {}).filter(([key]) => !SERIES_META_KEYS.has(key)),
  );
}

function toArray(value) {
  return Array.isArray(value) ? value : [];
}

function toSecondsTimestamp(value) {
  if (typeof value !== "number") {
    return value;
  }

  return value > 1_000_000_000_000 ? value : value * 1000;
}

export class ChartHook extends ViewHook {
  uPlot = uPlot;
  chart = null;
  data = [];
  opts = {};
  payload = {};
  colorResolutionCache = new Map();
  root = null;
  tooltip = null;
  resizeObserver = null;
  size = { width: 0, height: 0 };
  structureSignature = null;
  dataSignature = null;

  mounted() {
    this.cacheElements();
    this.connectResizeObserver();
    this.renderChart(true);
  }

  updated() {
    this.cacheElements();
    this.renderChart();
  }

  destroyed() {
    this.hideTooltip();
    this.resizeObserver?.disconnect();
    this.resizeObserver = null;
    this.destroyChart();
  }

  cacheElements() {
    this.root = this.el.querySelector("[data-chart-root]");
    this.tooltip = this.el.querySelector("[data-chart-tooltip]");
  }

  connectResizeObserver() {
    this.resizeObserver?.disconnect();

    if (!this.root) {
      return;
    }

    this.resizeObserver = new ResizeObserver(() => {
      if (!this.chart) {
        return;
      }

      const nextSize = this.measureSize(this.payload);

      if (
        nextSize.width === this.size.width &&
        nextSize.height === this.size.height
      ) {
        return;
      }

      this.size = nextSize;
      this.chart.setSize(nextSize);
      this.updateTooltipPosition(this.chart);
    });

    this.resizeObserver.observe(this.root);
  }

  readPayload() {
    try {
      return JSON.parse(this.el.dataset.chartConfig || "{}");
    } catch (_error) {
      return {};
    }
  }

  inferPreset(rawPayload) {
    if (rawPayload?.preset) {
      return rawPayload.preset;
    }

    const inferred = this.constructor.name
      .replace(/Hook$/, "")
      .replace(/Chart$/, "")
      .toLowerCase();

    return inferred === "chart" ? null : inferred;
  }

  normalizePayload(rawPayload) {
    const payload = rawPayload || {};

    return {
      ...payload,
      preset: this.inferPreset(payload),
      data: toArray(payload.data),
      series: toArray(payload.series),
      options: isPlainObject(payload.options) ? payload.options : {},
      tooltip: mergeDeep({ show: true }, payload.tooltip || {}),
      legend: mergeDeep({ show: false }, payload.legend || {}),
      grid: payload.grid !== false,
      height: payload.height || DEFAULT_HEIGHT,
    };
  }

  measureSize(payload) {
    const width = Math.max(
      Math.round(this.root?.clientWidth || this.el.clientWidth || 0),
      240,
    );

    return {
      width,
      height: payload.height || DEFAULT_HEIGHT,
    };
  }

  renderChart(force = false) {
    if (!this.root) {
      return;
    }

    const payload = this.normalizePayload(this.readPayload());
    const size = this.measureSize(payload);
    const structureSignature = JSON.stringify({
      ...payload,
      data: undefined,
      width: size.width,
      height: size.height,
    });
    const dataSignature = JSON.stringify(payload.data);

    this.payload = payload;
    this.size = size;

    if (
      !this.chart ||
      force ||
      structureSignature !== this.structureSignature
    ) {
      this.rebuildChart(payload, size);
      this.structureSignature = structureSignature;
      this.dataSignature = dataSignature;
      return;
    }

    const nextData = this.buildData(payload);
    const nextOpts = this.buildOptions(payload, size);

    this.data = nextData;
    this.opts = nextOpts;

    if (dataSignature !== this.dataSignature) {
      this.chart.setData(nextData, payload.reset_scales !== false);
      this.dataSignature = dataSignature;
    }

    if (size.width !== this.chart.width || size.height !== this.chart.height) {
      this.chart.setSize(size);
    }
  }

  rebuildChart(payload, size) {
    this.destroyChart();
    this.data = this.buildData(payload);
    this.opts = this.buildOptions(payload, size);
    this.chart = new this.uPlot(this.opts, this.data, this.root);
    this.hideTooltip();
  }

  destroyChart() {
    if (!this.chart) {
      return;
    }

    this.chart.destroy();
    this.chart = null;
  }

  buildData(payload) {
    return toArray(payload.data);
  }

  buildOptions(payload, size) {
    const preset = payload.preset;

    const defaults = {
      width: size.width,
      height: size.height,
      padding: [10, 8, 6, 0],
      focus: { alpha: 0.3 },
      legend: {
        show: payload.legend?.show === true,
        live: payload.legend?.live ?? true,
      },
      cursor: {
        y: false,
        x: true,
        focus: { prox: 24 },
        points: { show: false },
      },
      select: { show: false },
      axes: this.buildAxes(payload),
      scales: this.buildScales(payload),
      series: [{}, ...this.buildSeries(payload, preset)],
    };

    const options = mergeDeep(defaults, payload.options);
    options.width = size.width;
    options.height = size.height;
    options.hooks = this.mergeHooks(options.hooks, this.buildHooks(payload));

    return this.resolveColors(options);
  }

  buildScales(payload) {
    const xLength = toArray(payload.data[0]).length;

    if (payload.preset === "bar") {
      return {
        x: { time: false, range: [-0.5, Math.max(xLength - 0.5, 0.5)] },
        y: { auto: true },
      };
    }

    if (payload.time) {
      return {
        x: { time: true },
        y: { auto: true },
      };
    }

    return {
      x: { time: false },
      y: { auto: true },
    };
  }

  buildAxes(payload) {
    const font = this.axisFont();
    const axisColor = this.resolveCssValue("var(--chart-axis-color)");
    const gridColor = this.resolveCssValue("var(--chart-grid-color)");
    const baseX = {
      ticks: { show: false },
      border: { show: false },
      grid: { show: false },
      gap: 6,
      size: 28,
      font,
      stroke: axisColor,
    };
    const baseY = {
      ticks: { show: false },
      border: { show: false },
      grid: { show: payload.grid, stroke: gridColor, width: 0.5 },
      gap: 6,
      size: 52,
      font,
      stroke: axisColor,
      values: (_self, values) =>
        values.map((value) => this.formatNumericValue(value, payload.y_axis)),
    };

    if (payload.time) {
      return [baseX, baseY];
    }

    if (Array.isArray(payload.categories) && payload.categories.length > 0) {
      return [
        {
          ...baseX,
          values: (_self, values) =>
            values.map((value) => this.lookupLabel(payload.categories, value)),
        },
        baseY,
      ];
    }

    if (Array.isArray(payload.labels) && payload.labels.length > 0) {
      return [
        {
          ...baseX,
          values: (_self, values) =>
            values.map((value) => this.lookupLabel(payload.labels, value)),
        },
        baseY,
      ];
    }

    return [baseX, baseY];
  }

  buildSeries(payload, preset) {
    return payload.series.map((series, index) => {
      const stroke = this.resolveCssValue(
        series.color || series.stroke || this.paletteColor(index),
      );
      const shared = {
        label: series.label || series.name || `Series ${index + 1}`,
        stroke,
        width: series.width ?? (preset === "bar" ? 0 : 2),
        points: mergeDeep({ show: false }, series.points || {}),
      };
      const nextSeries = mergeDeep(shared, stripSeriesMeta(series));

      if (preset === "bar") {
        nextSeries.fill = this.resolveCssValue(series.fill || stroke);
        nextSeries.paths = this.uPlot.paths.bars({
          size: payload.bar?.size || DEFAULT_BAR_SIZE,
          radius: payload.bar?.radius ?? 0.1,
        });
      }

      if (preset === "line") {
        if (payload.area || series.area) {
          nextSeries.fill = this.resolveCssValue(
            series.fill || this.withAlpha(stroke, 0.18),
          );
        }

        nextSeries.paths = this.resolveLinePath(series, payload);
      }

      return nextSeries;
    });
  }

  resolveLinePath(series, payload) {
    const curve = series.curve || payload.curve || "linear";

    switch (curve) {
      case "stepped":
        return this.uPlot.paths.stepped({ align: 1 });
      case "spline":
        return this.uPlot.paths.spline();
      default:
        return this.uPlot.paths.linear();
    }
  }

  buildHooks(payload) {
    return {
      setCursor: [
        (chart) => {
          if (!payload.tooltip?.show) {
            return;
          }

          this.updateTooltipPosition(chart);
        },
      ],
      setSeries: [
        () => {
          this.hideTooltip();
        },
      ],
      destroy: [
        () => {
          this.hideTooltip();
        },
      ],
    };
  }

  mergeHooks(existingHooks = {}, additionalHooks = {}) {
    const keys = new Set([
      ...Object.keys(existingHooks || {}),
      ...Object.keys(additionalHooks || {}),
    ]);

    return Array.from(keys).reduce((hooks, key) => {
      hooks[key] = [
        ...toArray(existingHooks?.[key]),
        ...toArray(additionalHooks?.[key]),
      ];

      return hooks;
    }, {});
  }

  updateTooltipPosition(chart) {
    if (!this.tooltip) {
      return;
    }

    const idx = chart?.cursor?.idx;
    const left = chart?.cursor?.left;
    const top = chart?.cursor?.top;

    if (idx == null || left == null || top == null || left < 0 || top < 0) {
      this.hideTooltip();
      return;
    }

    const rows = this.tooltipRows(chart, idx);

    if (rows.length === 0) {
      this.hideTooltip();
      return;
    }

    this.renderTooltipContent(chart, idx, rows);

    const rect = chart.over.getBoundingClientRect();
    const x = rect.left + left;
    const y = rect.top + top;
    const virtualElement = {
      getBoundingClientRect: () => new DOMRect(x, y, 0, 0),
    };

    this.tooltip.classList.remove("hidden");

    computePosition(virtualElement, this.tooltip, {
      strategy: "fixed",
      placement: "top-start",
      middleware: [offset(14), flip(), shift({ padding: 12 })],
    }).then(({ x: tooltipX, y: tooltipY }) => {
      Object.assign(this.tooltip.style, {
        left: `${tooltipX}px`,
        top: `${tooltipY}px`,
      });
    });
  }

  tooltipRows(chart, idx) {
    return chart.series
      .slice(1)
      .map((series, offset) => {
        const value = chart.data[offset + 1]?.[idx];

        if (value == null || series.show === false) {
          return null;
        }

        const config = this.payload.series[offset] || {};
        const color = this.resolveCssValue(
          config.color || config.stroke || this.paletteColor(offset),
        );

        return {
          label: series.label,
          color,
          value: this.formatSeriesValue(value, config),
        };
      })
      .filter(Boolean);
  }

  renderTooltipContent(chart, idx, rows) {
    if (!this.tooltip) {
      return;
    }

    const title = document.createElement("div");
    title.className = "pui-chart-tooltip__title";
    title.textContent = this.tooltipTitle(chart, idx);

    const list = document.createElement("div");
    list.className = "pui-chart-tooltip__list";

    rows.forEach((row) => {
      const item = document.createElement("div");
      item.className = "pui-chart-tooltip__row";

      const label = document.createElement("div");
      label.className = "pui-chart-tooltip__label";

      const marker = document.createElement("span");
      marker.className = "pui-chart-tooltip__marker";
      marker.style.backgroundColor = row.color;

      const text = document.createElement("span");
      text.textContent = row.label;

      const value = document.createElement("span");
      value.className = "pui-chart-tooltip__value";
      value.textContent = row.value;

      label.append(marker, text);
      item.append(label, value);
      list.append(item);
    });

    this.tooltip.replaceChildren(title, list);
  }

  tooltipTitle(chart, idx) {
    if (this.payload.tooltip?.title) {
      return this.payload.tooltip.title;
    }

    const xValue = chart.data[0]?.[idx];

    if (
      Array.isArray(this.payload.categories) &&
      this.payload.categories[idx] != null
    ) {
      return `${this.payload.categories[idx]}`;
    }

    if (
      Array.isArray(this.payload.labels) &&
      this.payload.labels[idx] != null
    ) {
      return `${this.payload.labels[idx]}`;
    }

    if (this.payload.time) {
      const formatter = new Intl.DateTimeFormat(undefined, {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });

      return formatter.format(new Date(toSecondsTimestamp(xValue)));
    }

    return `${xValue}`;
  }

  formatSeriesValue(value, series) {
    const number = this.formatNumericValue(value, series);
    const prefix = series.prefix || "";
    const suffix = series.suffix || "";
    return `${prefix}${number}${suffix}`;
  }

  formatNumericValue(value, config = {}) {
    if (typeof value !== "number") {
      return `${value}`;
    }

    if (Number.isInteger(value) && config.precision == null) {
      return new Intl.NumberFormat(undefined).format(value);
    }

    const maximumFractionDigits =
      config.precision != null ? config.precision : value % 1 === 0 ? 0 : 2;

    return new Intl.NumberFormat(undefined, {
      maximumFractionDigits,
    }).format(value);
  }

  lookupLabel(labels, value) {
    const index = Math.round(value);
    return index >= 0 && index < labels.length ? `${labels[index]}` : "";
  }

  hideTooltip() {
    if (!this.tooltip) {
      return;
    }

    this.tooltip.classList.add("hidden");
    this.tooltip.replaceChildren();
  }

  axisFont() {
    const fontFamily =
      getComputedStyle(this.el).getPropertyValue("--font-sans").trim() ||
      "system-ui, sans-serif";

    return `12px ${fontFamily}`;
  }

  paletteColor(index) {
    return `var(${DEFAULT_PALETTE[index % DEFAULT_PALETTE.length]})`;
  }

  resolveCssValue(value) {
    if (typeof value !== "string") {
      return value;
    }

    const match = value.trim().match(/^var\((--[^)]+)\)$/);
    const resolved = match
      ? getComputedStyle(this.el).getPropertyValue(match[1]).trim() || value
      : value;

    return this.resolveCanvasColor(resolved);
  }

  resolveCanvasColor(value) {
    if (!this.isColorLikeValue(value)) {
      return value;
    }

    const trimmed = value.trim();
    const cached = this.colorResolutionCache.get(trimmed);

    if (cached) {
      return cached;
    }

    const probe = document.createElement("span");
    probe.style.color = trimmed;
    probe.style.position = "absolute";
    probe.style.visibility = "hidden";
    probe.style.pointerEvents = "none";

    this.el.appendChild(probe);
    const resolved = getComputedStyle(probe).color || trimmed;
    probe.remove();

    this.colorResolutionCache.set(trimmed, resolved);

    return resolved;
  }

  withAlpha(color, alpha) {
    const resolved = this.resolveCanvasColor(color);
    const match = resolved.match(/^rgba?\(([^)]+)\)$/i);

    if (!match) {
      return resolved;
    }

    const [red, green, blue] = match[1]
      .split(",")
      .slice(0, 3)
      .map((channel) => channel.trim());

    return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
  }

  isColorLikeValue(value) {
    if (typeof value !== "string") {
      return false;
    }

    const trimmed = value.trim();

    return (
      /^#(?:[\da-f]{3,8})$/i.test(trimmed) ||
      /^(?:rgb|rgba|hsl|hsla|hwb|lab|lch|oklab|oklch|color|color-mix)\(/i.test(
        trimmed,
      )
    );
  }

  resolveColors(value) {
    if (Array.isArray(value)) {
      return value.map((entry) => this.resolveColors(entry));
    }

    if (isPlainObject(value)) {
      return Object.fromEntries(
        Object.entries(value).map(([key, entry]) => [
          key,
          this.resolveColors(entry),
        ]),
      );
    }

    return this.resolveCssValue(value);
  }
}

export default ChartHook;
