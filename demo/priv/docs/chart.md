%{
  title: "Chart",
  description: "uPlot-powered charts for LiveView with preconfigured bar and line variants, tooltips, and extendable hooks.",
  group: "Data Display",
  order: 3,
  icon: "hero-chart-bar"
}
---

The Chart component brings uPlot into PUI with a LiveView-friendly API. The server sends serializable config, while the hook builds and updates the client-side chart instance during mount, patch, resize, and teardown.

## Import

```elixir
use PUI
# or
import PUI.Chart
```

## Low-level Chart

Use `<.chart>` when you want full control over the payload and hook pairing.

```heex
<.chart
  id="deploys"
  hook="PUI.BarChart"
  height={280}
  config=%{
    preset: "bar",
    categories: ["Jan", "Feb", "Mar", "Apr"],
    data: [
      [0, 1, 2, 3],
      [4.2, 6.0, 5.1, 7.3]
    ],
    series: [
      %{label: "Deploys", suffix: "x"}
    ]
  }
/>
```

<AppWeb.DocsDemo.chart_base_demo />

## Preconfigured Bar Chart

Use `<.bar_chart>` for categorical comparisons. It generates the aligned x-axis data for you and wires the default `PUI.BarChart` hook.

```heex
<.bar_chart
  id="monthly-revenue"
  categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
  series={[
    %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1, 19.8, 25.3], suffix: " jt"},
    %{label: "Target", data: [10.0, 14.0, 16.0, 18.0, 20.0, 24.0], suffix: " jt"}
  ]}
/>
```

<AppWeb.DocsDemo.chart_bar_demo />

## Preconfigured Line Chart

Use `<.line_chart>` for trend data. Switch between `linear`, `stepped`, and `spline` path renderers through the component API while LiveView patches the existing hook payload.

```heex
<.line_chart
  id="server-temps"
  curve={@chart_curve}
  labels={["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"]}
  series={[
    %{label: "Server A", data: [41.2, 43.8, 46.5, 45.1, 44.6, 42.9], suffix: "°C"},
    %{label: "Server B", data: [36.4, 37.8, 39.2, 40.3, 39.4, 38.1], suffix: "°C"}
  ]}
/>
```

<AppWeb.DocsDemo.chart_line_demo chart_curve={@chart_curve} chart_revision={@chart_revision} />

## Extending the Hook

The base hook exports `this.uPlot`, `this.chart`, `this.data`, and `this.opts`. That means derivative hooks can stay very small:

```javascript
import { ChartHook } from "pui";

export default class BarChart extends ChartHook {}
```

For custom behavior, subclass `ChartHook`, keep the component payload serializable, and override the relevant methods such as `buildSeries(payload)`, `buildAxes(payload)`, or `buildHooks(payload)`.

## API Reference

### `<.chart>`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique chart DOM id |
| `hook` | `string` | `"PUI.Chart"` | Hook that renders the chart |
| `height` | `integer` | `320` | Reserved chart height in pixels |
| `class` | `string` | `""` | Additional wrapper classes |
| `config` | `map` | required | Serializable chart payload consumed by the hook |

### `<.bar_chart>`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `categories` | `list` | required | Labels used on the x-axis |
| `series` | `list` | required | Series maps containing `label` and `data` |
| `bar_width` | `float` | `0.72` | Relative bar width passed to `uPlot.paths.bars/1` |
| `max_bar_width` | `integer` | `64` | Maximum rendered bar width in pixels |
| `grid` | `boolean` | `true` | Toggles the y-axis grid |
| `legend` | `boolean` | `false` | Enables the built-in uPlot legend |
| `tooltip` | `map` | `%{}` | Tooltip configuration |
| `options` | `map` | `%{}` | Additional serialized chart options |

### `<.line_chart>`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `x` | `list` | generated | Explicit x-axis values |
| `labels` | `list` | `[]` | Optional categorical x-axis labels |
| `series` | `list` | required | Series maps containing `label` and `data` |
| `curve` | `string` | `"linear"` | `"linear"`, `"stepped"`, or `"spline"` |
| `time` | `boolean` | `false` | Enables a temporal x-axis |
| `area` | `boolean` | `false` | Adds a fill beneath each line |
| `grid` | `boolean` | `true` | Toggles the y-axis grid |
| `legend` | `boolean` | `false` | Enables the built-in uPlot legend |
| `tooltip` | `map` | `%{}` | Tooltip configuration |
| `options` | `map` | `%{}` | Additional serialized chart options |
