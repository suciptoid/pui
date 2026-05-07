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

Use the low-level `chart/1` component when you want full control over the payload and hook pairing.

```heex
<.chart
  id="deploys"
  phx-hook="PUI.BarChart"
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

Use `bar_chart/1` for categorical comparisons. It generates the aligned x-axis data for you and defaults `phx-hook` to `PUI.BarChart`.

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

Use `line_chart/1` for trend data. Switch between `linear`, `stepped`, and `spline` path renderers through the component API while LiveView patches the existing hook payload. Each series also accepts `color` as a convenient alias for the line color, plus optional `fill`, `width`, and formatting keys.

```heex
<.line_chart
  id="server-temps"
  curve={@chart_curve}
  area={@chart_show_area}
  grid={@chart_show_grid}
  labels={["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"]}
  tooltip={%{title: "Page Views"}}
  series={[
    %{label: "Desktop", color: @chart_color, data: [186, 202, 194, 228, 246, 268]}
  ]}
/>
```

<AppWeb.DocsDemo.chart_line_demo chart_color={@chart_color} chart_curve={@chart_curve} chart_revision={@chart_revision} chart_show_area={@chart_show_area} chart_show_grid={@chart_show_grid} />

## Extending the Hook

The base hook exports `this.uPlot`, `this.chart`, `this.data`, and `this.opts`. That means derivative hooks can stay very small:

```javascript
import { ChartHook } from "pui";

export default class BarChart extends ChartHook {}
```

For custom behavior, subclass `ChartHook`, keep the component payload serializable, and override the relevant methods such as `buildSeries(payload)`, `buildAxes(payload)`, or `buildHooks(payload)`.

### Colocated hook example

When a chart should only live next to one LiveView or demo, use a colocated hook directly in the HEEx template. This avoids separate files and manual LiveSocket registration — colocated hooks are automatically bundled.

Create a hook that hides axes, grid, and cursor for a minimal look:

```heex
<.line_chart
  id="mini-temps"
  phx-hook=".MiniChart"
  labels={["00:00", "04:00", "08:00", "12:00"]}
  series={[
    %{label: "CPU", data: [42, 45, 43, 46], suffix: "°C"}
  ]}
/>
<script :type={Phoenix.LiveView.ColocatedHook} name=".MiniChart">
  import { LineChart } from "pui";
  export default class MiniChart extends LineChart {
    buildAxes(payload) {
      return [{ show: false }, { show: false }];
    }
  }
</script>
```

The hook name must start with a `.` prefix and the script must use `:type={Phoenix.LiveView.ColocatedHook}` — never raw `<script>` tags. That keeps the component payload serializable while letting the colocated hook hide grid lines, cursor chrome, and axis labels for just that one chart.

## API Reference

### `chart/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique chart DOM id |
| `phx-hook` | global attr | `"PUI.Chart"` | Hook that renders the chart |
| `height` | `integer` | `320` | Reserved chart height in pixels |
| `class` | `string` | `""` | Additional wrapper classes |
| `card` | `boolean` | `true` | Wraps the chart in a bordered card container |
| `config` | `map` | required | Serializable chart payload consumed by the hook |

### `bar_chart/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique chart DOM id |
| `categories` | `list` | required | Labels used on the x-axis |
| `series` | `list` | required | Series maps containing `label` and `data` |
| `height` | `integer` | `320` | Reserved chart height in pixels |
| `class` | `string` | `""` | Additional wrapper classes |
| `card` | `boolean` | `true` | Wraps the chart in a bordered card container |
| `bar_width` | `float` | `0.72` | Relative bar width passed to `uPlot.paths.bars/1` |
| `max_bar_width` | `integer` | `64` | Maximum rendered bar width in pixels |
| `bar_radius` | `integer` | `2` | Top corner radius in pixels for rendered bars |
| `grid` | `boolean` | `true` | Toggles the y-axis grid |
| `legend` | `boolean` | `false` | Enables the built-in uPlot legend |
| `tooltip` | `map` | `%{}` | Tooltip configuration |
| `options` | `map` | `%{}` | Additional serialized chart options |

### `line_chart/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique chart DOM id |
| `x` | `list` | generated | Explicit x-axis values |
| `labels` | `list` | `[]` | Optional categorical x-axis labels |
| `series` | `list` | required | Series maps containing `label` and `data` |
| `curve` | `string` | `"linear"` | `"linear"`, `"stepped"`, or `"spline"` |
| `time` | `boolean` | `false` | Enables a temporal x-axis |
| `area` | `boolean` | `false` | Adds a fill beneath each line |
| `sparkline` | `boolean` | `false` | Switches to the compact `PUI.SparklineChart` hook |
| `height` | `integer` | `320` | Reserved chart height in pixels |
| `class` | `string` | `""` | Additional wrapper classes |
| `card` | `boolean` | `true` | Wraps the chart in a bordered card container |
| `grid` | `boolean` | `true` | Toggles the y-axis grid |
| `legend` | `boolean` | `false` | Enables the built-in uPlot legend |
| `tooltip` | `map` | `%{}` | Tooltip configuration |
| `options` | `map` | `%{}` | Additional serialized chart options |
