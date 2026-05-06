defmodule PUI.Chart do
  @moduledoc """
  uPlot-backed chart components for Phoenix LiveView.

  `PUI.Chart` ships three layers:

  1. `<.chart>` is the low-level transport component that sends serializable chart
     config to a LiveView hook.
  2. `<.bar_chart>` provides preconfigured categorical bar charts.
  3. `<.line_chart>` provides preconfigured line charts with linear, stepped, and
     spline paths.

  The companion hooks expose `this.uPlot`, `this.chart`, `this.data`, and
  `this.opts` so downstream hooks can extend the base chart behavior without
  rebuilding the LiveView component contract.

  ## Basic usage

      <.bar_chart
        id="monthly-sales"
        categories={~w(Jan Feb Mar Apr)}
        series={[
          %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1], suffix: " jt"}
        ]}
      />

      <.line_chart
        id="servers"
        curve="stepped"
        labels={["00:00", "06:00", "12:00", "18:00"]}
        series={[
          %{label: "Server A", data: [42, 45, 43, 46], suffix: "°C"},
          %{label: "Server B", data: [38, 40, 39, 41], suffix: "°C"}
        ]}
      />

      <.chart
        id="custom-chart"
        hook="PUI.Chart"
        height={280}
        config=%{
          data: [
            [1, 2, 3, 4],
            [12, 18, 15, 20]
          ],
          series: [
            %{label: "Traffic", stroke: "var(--chart-1)"}
          ],
          options: %{
            scales: %{x: %{time: false}, y: %{auto: true}}
          }
        }
      />

  ## Attributes

  `chart/1`

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | generated | Unique DOM id for the chart root |
  | `hook` | `string` | `"PUI.Chart"` | Hook name used to render/update the chart |
  | `height` | `integer` | `320` | Reserved chart height in pixels |
  | `class` | `string` | `""` | Additional classes for the outer chart wrapper |
  | `config` | `map` | required | Serializable chart payload consumed by the hook |
  | `rest` | `global` | — | Additional HTML attributes |

  `bar_chart/1`

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `categories` | `list` | required | Labels shown on the x-axis |
  | `series` | `list` | required | Series maps with `label` and `data` |
  | `bar_width` | `float` | `0.72` | Relative bar width passed to `uPlot.paths.bars/1` |
  | `max_bar_width` | `integer` | `64` | Maximum rendered bar width in pixels |
  | `grid` | `boolean` | `true` | Toggles the y-axis grid |
  | `tooltip` | `map` | `%{}` | Tooltip configuration merged into defaults |
  | `legend` | `boolean` | `false` | Toggles the built-in uPlot legend |
  | `options` | `map` | `%{}` | Additional serialized chart options |

  `line_chart/1`

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `x` | `list` | generated | Explicit x-axis values |
  | `labels` | `list` | `[]` | Optional categorical x-axis labels for non-time charts |
  | `series` | `list` | required | Series maps with `label` and `data` |
  | `curve` | `string` | `"linear"` | One of `"linear"`, `"stepped"`, or `"spline"` |
  | `time` | `boolean` | `false` | Enables uPlot's time scale for the x-axis |
  | `area` | `boolean` | `false` | Adds area fills beneath line series |
  | `grid` | `boolean` | `true` | Toggles the y-axis grid |
  | `tooltip` | `map` | `%{}` | Tooltip configuration merged into defaults |
  | `legend` | `boolean` | `false` | Toggles the built-in uPlot legend |
  | `options` | `map` | `%{}` | Additional serialized chart options |
  """

  use Phoenix.Component

  attr :id, :string, default: nil
  attr :hook, :string, default: "PUI.Chart"
  attr :height, :integer, default: 320
  attr :class, :string, default: ""
  attr :config, :map, required: true
  attr :rest, :global

  def chart(assigns) do
    height = map_get(assigns.config, :height) || assigns.height

    assigns =
      assigns
      |> assign_new(:id, fn -> "chart-#{System.unique_integer([:positive])}" end)

    assigns =
      assign(assigns,
        height: height,
        root_id: "#{assigns.id}-root",
        tooltip_id: "#{assigns.id}-tooltip",
        encoded_config: assigns.config |> Map.put_new(:height, height) |> encode_config!()
      )

    ~H"""
    <div
      id={@id}
      phx-hook={@hook}
      data-chart-config={@encoded_config}
      class={["pui-chart flex w-full flex-col gap-3", @class]}
      {@rest}
    >
      <div class="overflow-hidden rounded-[calc(var(--radius)+2px)] border border-border/70 bg-card/50 p-4 shadow-sm sm:p-5">
        <div
          id={@root_id}
          data-chart-root
          phx-update="ignore"
          style={"height: #{@height}px"}
          class="relative min-h-0 w-full"
        >
        </div>
      </div>

      <div
        id={@tooltip_id}
        data-chart-tooltip
        phx-update="ignore"
        role="tooltip"
        class="pui-chart-tooltip pointer-events-none fixed left-0 top-0 z-50 hidden min-w-44 rounded-xl border border-border/70 bg-popover/95 px-3 py-2 text-xs text-popover-foreground shadow-lg backdrop-blur-sm"
      >
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :hook, :string, default: "PUI.BarChart"
  attr :height, :integer, default: 320
  attr :class, :string, default: ""
  attr :categories, :list, required: true
  attr :series, :list, required: true
  attr :bar_width, :float, default: 0.72
  attr :max_bar_width, :integer, default: 64
  attr :grid, :boolean, default: true
  attr :tooltip, :map, default: %{}
  attr :legend, :boolean, default: false
  attr :options, :map, default: %{}
  attr :rest, :global

  def bar_chart(assigns) do
    {series_data, series_config} = normalize_series!(assigns.series, "bar_chart")
    expected_points = length(assigns.categories)

    validate_series_lengths!(series_data, expected_points, "bar_chart")

    x_values =
      if expected_points == 0 do
        []
      else
        Enum.to_list(0..(expected_points - 1))
      end

    config = %{
      preset: "bar",
      categories: assigns.categories,
      data: [x_values | series_data],
      series: series_config,
      grid: assigns.grid,
      legend: %{show: assigns.legend},
      tooltip: assigns.tooltip,
      bar: %{size: [assigns.bar_width, assigns.max_bar_width]},
      options: assigns.options
    }

    assigns
    |> assign(:config, config)
    |> chart()
  end

  attr :id, :string, default: nil
  attr :hook, :string, default: "PUI.LineChart"
  attr :height, :integer, default: 320
  attr :class, :string, default: ""
  attr :x, :list, default: nil
  attr :labels, :list, default: []
  attr :series, :list, required: true
  attr :curve, :string, values: ["linear", "stepped", "spline"], default: "linear"
  attr :time, :boolean, default: false
  attr :area, :boolean, default: false
  attr :grid, :boolean, default: true
  attr :tooltip, :map, default: %{}
  attr :legend, :boolean, default: false
  attr :options, :map, default: %{}
  attr :rest, :global

  def line_chart(assigns) do
    {series_data, series_config} = normalize_series!(assigns.series, "line_chart")
    expected_points = series_data |> List.first([]) |> length()

    validate_series_lengths!(series_data, expected_points, "line_chart")

    x_values =
      cond do
        is_list(assigns.x) ->
          if length(assigns.x) != expected_points do
            raise ArgumentError,
                  "expected line_chart x values length to match each series length"
          end

          assigns.x

        expected_points == 0 ->
          []

        true ->
          Enum.to_list(0..(expected_points - 1))
      end

    config = %{
      preset: "line",
      curve: assigns.curve,
      time: assigns.time,
      area: assigns.area,
      labels: assigns.labels,
      data: [x_values | series_data],
      series: series_config,
      grid: assigns.grid,
      legend: %{show: assigns.legend},
      tooltip: assigns.tooltip,
      options: assigns.options
    }

    assigns
    |> assign(:config, config)
    |> chart()
  end

  defp normalize_series!(series, component_name) when is_list(series) do
    Enum.map(series, &normalize_series_entry!(&1, component_name))
    |> Enum.unzip()
  end

  defp normalize_series!(_series, component_name) do
    raise ArgumentError, "#{component_name} expects series to be a list of maps"
  end

  defp normalize_series_entry!(series, component_name) when is_map(series) do
    data = map_get(series, :data)

    unless is_list(data) do
      raise ArgumentError,
            "#{component_name} expects every series map to include a list under :data"
    end

    config =
      series
      |> Map.new()
      |> drop_map_keys([:data, "data"])
      |> put_label_default()

    {data, config}
  end

  defp normalize_series_entry!(_series, component_name) do
    raise ArgumentError, "#{component_name} expects every series entry to be a map"
  end

  defp validate_series_lengths!(series_data, expected_points, component_name) do
    Enum.each(series_data, fn data ->
      if length(data) != expected_points do
        raise ArgumentError,
              "#{component_name} expects every series data list to have #{expected_points} points"
      end
    end)
  end

  defp put_label_default(series) do
    label = map_get(series, :label) || map_get(series, :name)

    if label do
      Map.put_new(series, :label, label)
    else
      series
    end
  end

  defp drop_map_keys(map, keys) do
    Enum.reduce(keys, map, fn key, acc -> Map.delete(acc, key) end)
  end

  defp map_get(map, key) when is_map(map) do
    Map.get(map, key, Map.get(map, Atom.to_string(key)))
  end

  defp encode_config!(config) do
    Phoenix.json_library().encode!(config)
  end
end
