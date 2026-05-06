%{
  title: "ComposeChart",
  description: "Declarative, composable chart components for LiveView. Build charts by composing child components like bars, lines, axes, tooltips, and legends.",
  group: "Data Display",
  order: 4,
  icon: "hero-chart-bar"
}
---

`PUI.ComposeChart` provides a declarative, child-component-based API for building charts — similar to Recharts in React. Each child renders a hidden config element that the `PUI.ComposeChart` JS hook collects and merges on the client to build the final uPlot chart.

## Import

```elixir
import PUI.ComposeChart
```

Then use the short form:

```heex
<.container id="my-chart">
  <.x_axis categories={["Jan", "Feb", "Mar"]} />
  <.bar series={[...]} />
</.container>
```

Or use the fully qualified form without importing:

```heex
<PUI.ComposeChart.container id="my-chart">
  <PUI.ComposeChart.x_axis categories={["Jan", "Feb", "Mar"]} />
  <PUI.ComposeChart.bar series={[...]} />
</PUI.ComposeChart.container>
```

## Bar Chart

Compose a bar chart by pairing a container with axis, tooltip, and bar children.

```heex
<.container id="revenue" height={300}>
  <.x_axis categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]} />
  <.y_axis />
  <.tooltip />
  <.legend />
  <.bar series={[
    %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1, 19.8, 25.3], suffix: " jt"},
    %{label: "Target", data: [10.0, 14.0, 16.0, 18.0, 20.0, 24.0], suffix: " jt"}
  ]} />
</.container>
```

<AppWeb.DocsDemo.compose_chart_bar_demo />

## Line Chart

Use `<.line>` for trend data. Switch between `linear`, `stepped`, and `spline` curves, and enable area fills.

```heex
<.container id="server-temps" height={300}>
  <.x_axis labels={["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"]} />
  <.tooltip title="Server temps" />
  <.line
    curve="spline"
    area={true}
    series={[
      %{label: "Server A", data: [42, 45, 43, 46, 44, 47], suffix: "°C"},
      %{label: "Server B", data: [38, 40, 39, 41, 40, 42], suffix: "°C"}
    ]}
  />
</.container>
```

<AppWeb.DocsDemo.compose_chart_line_demo />

## Mixed Content

You can place arbitrary HTML alongside chart children. The container renders them above the chart area.

```heex
<.container id="annotated-chart">
  <div class="mb-2 text-sm text-muted-foreground">Live metrics</div>
  <.x_axis categories={~w(Mon Tue Wed Thu Fri)} />
  <.bar series={[%{label: "Tasks", data: [28, 34, 31, 39, 42]}]} />
</.container>
```

## Child Components

| Component | Purpose | Key attrs |
|-----------|---------|-----------|
| `<.container>` | Chart wrapper | `id`, `hook`, `height`, `class`, `card` |
| `<.tooltip>` | Tooltip config | `show`, `title` |
| `<.legend>` | Legend visibility | `show` |
| `<.x_axis>` | X-axis labels | `categories`, `labels`, `time` |
| `<.y_axis>` | Y-axis presence | — |
| `<.bar>` | Bar series | `series` (required), `bar_width`, `max_bar_width` |
| `<.line>` | Line series | `series` (required), `curve`, `area`, `time`, `labels`, `x` |

## API Reference

### `container/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique chart DOM id |
| `hook` | `string` | `"PUI.ComposeChart"` | Hook that renders the chart |
| `height` | `integer` | `320` | Reserved chart height in pixels |
| `class` | `string` | `""` | Additional wrapper classes |
| `card` | `boolean` | `true` | Wraps the chart in a bordered card container |

### `bar/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `series` | `list` | required | Series maps containing `label` and `data` |
| `bar_width` | `float` | `0.72` | Relative bar width passed to `uPlot.paths.bars/1` |
| `max_bar_width` | `integer` | `64` | Maximum rendered bar width in pixels |

### `line/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `series` | `list` | required | Series maps containing `label` and `data` |
| `curve` | `string` | `"linear"` | `"linear"`, `"stepped"`, or `"spline"` |
| `area` | `boolean` | `false` | Adds a fill beneath each line |
| `time` | `boolean` | `false` | Enables a temporal x-axis |
| `labels` | `list` | `[]` | Optional categorical x-axis labels |
| `x` | `list` | `nil` | Explicit x-axis values |

### `x_axis/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `categories` | `list` | `[]` | Labels for categorical x-axis |
| `labels` | `list` | `[]` | Labels for indexed x-axis |
| `time` | `boolean` | `false` | Enables temporal x-axis |

### `tooltip/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `show` | `boolean` | `true` | Enables the tooltip |
| `title` | `string` | `nil` | Static tooltip title |

### `legend/1`

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `show` | `boolean` | `true` | Shows the legend |
