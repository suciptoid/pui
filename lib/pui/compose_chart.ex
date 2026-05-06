defmodule PUI.ComposeChart do
  @moduledoc """
  Composable chart components for Phoenix LiveView.

  `PUI.ComposeChart` provides a declarative, child-component-based API for building
  charts. Each child renders a hidden config element that the `PUI.ComposeChart`
  JS hook reads and merges on the client to build the final uPlot chart.

  ## Usage

      <PUI.ComposeChart.container id="revenue" height={300}>
        <PUI.ComposeChart.x_axis categories={~w(Jan Feb Mar Apr May Jun)} />
        <PUI.ComposeChart.y_axis />
        <PUI.ComposeChart.tooltip />
        <PUI.ComposeChart.legend />
        <PUI.ComposeChart.bar series={[
          %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1, 19.8, 25.3], suffix: " jt"}
        ]} />
      </PUI.ComposeChart.container>

  After `import PUI.ComposeChart` the short form also works:

      <.container id="revenue" height={300}>
        <.x_axis categories={~w(Jan Feb Mar Apr May Jun)} />
        <.tooltip />
        <.bar series={[...]} />
      </.container>
  """

  use Phoenix.Component

  # ---------------------------------------------------------------------------
  # Container
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :hook, :string, default: "PUI.ComposeChart"
  attr :height, :integer, default: 320
  attr :class, :string, default: ""
  attr :card, :boolean, default: true
  attr :rest, :global
  slot :inner_block

  def container(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "compose-chart-#{System.unique_integer([:positive])}" end)

    assigns =
      assign(assigns,
        root_id: "#{assigns.id}-root",
        tooltip_id: "#{assigns.id}-tooltip",
        encoded_config: encode_config!(%{height: assigns.height})
      )

    ~H"""
    <div
      id={@id}
      phx-hook={@hook}
      data-chart-config={@encoded_config}
      class={["pui-chart flex w-full flex-col", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}

      <div class={[
        @card &&
          "overflow-hidden rounded-[calc(var(--radius)+2px)] border border-border/60 bg-card p-4 shadow-sm sm:p-5"
      ]}>
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
        class="pui-chart-tooltip pointer-events-none fixed left-0 top-0 z-50 hidden min-w-40 rounded-2xl border border-border/50 bg-popover px-4 py-3 text-popover-foreground shadow-lg"
      >
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Child components
  # ---------------------------------------------------------------------------

  @doc """
  Configures the chart tooltip.

  ## Examples

      <.container id="my-chart">
        <.tooltip title="Revenue" />
        <.bar series={[...]} />
      </.container>
  """
  attr :show, :boolean, default: true
  attr :title, :string, default: nil
  attr :rest, :global

  def tooltip(assigns) do
    config = %{show: assigns.show}
    config = if assigns.title, do: Map.put(config, :title, assigns.title), else: config

    assigns = assign(assigns, config_json: encode_config!(config))

    ~H"""
    <div data-chart-child="tooltip" data-chart-config={@config_json} style="display:none" {@rest}>
    </div>
    """
  end

  @doc """
  Configures the chart legend.

  ## Examples

      <.container id="my-chart">
        <.legend />
        <.bar series={[...]} />
      </.container>
  """
  attr :show, :boolean, default: true
  attr :rest, :global

  def legend(assigns) do
    assigns = assign(assigns, config_json: encode_config!(%{show: assigns.show}))

    ~H"""
    <div data-chart-child="legend" data-chart-config={@config_json} style="display:none" {@rest}>
    </div>
    """
  end

  @doc """
  Configures the x-axis.

  ## Examples

      <.container id="my-chart">
        <.x_axis categories={~w(Jan Feb Mar Apr)} />
        <.bar series={[...]} />
      </.container>
  """
  attr :categories, :list, default: []
  attr :labels, :list, default: []
  attr :time, :boolean, default: false
  attr :rest, :global

  def x_axis(assigns) do
    config = %{}

    config =
      if assigns.categories != [],
        do: Map.put(config, :categories, assigns.categories),
        else: config

    config =
      if assigns.labels != [],
        do: Map.put(config, :labels, assigns.labels),
        else: config

    config = if assigns.time, do: Map.put(config, :time, true), else: config

    assigns = assign(assigns, config_json: encode_config!(config))

    ~H"""
    <div data-chart-child="x-axis" data-chart-config={@config_json} style="display:none" {@rest}>
    </div>
    """
  end

  @doc """
  Configures the y-axis.

  ## Examples

      <.container id="my-chart">
        <.y_axis />
        <.bar series={[...]} />
      </.container>
  """
  attr :rest, :global

  def y_axis(assigns) do
    assigns = assign(assigns, config_json: encode_config!(%{}))

    ~H"""
    <div data-chart-child="y-axis" data-chart-config={@config_json} style="display:none" {@rest}>
    </div>
    """
  end

  @doc """
  Adds a bar series.

  ## Examples

      <.container id="my-chart">
        <.x_axis categories={~w(Jan Feb Mar Apr)} />
        <.bar series={[
          %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1], suffix: " jt"}
        ]} />
      </.container>
  """
  attr :series, :list, required: true
  attr :bar_width, :float, default: 0.72
  attr :max_bar_width, :integer, default: 64
  attr :rest, :global

  def bar(assigns) do
    {series_data, series_config} = normalize_series!(assigns.series, "ComposeChart.bar")
    expected_points = series_data |> List.first([]) |> length()

    if expected_points > 0,
      do: validate_series_lengths!(series_data, expected_points, "ComposeChart.bar")

    config = %{
      series: series_config,
      series_data: series_data,
      bar_width: assigns.bar_width,
      max_bar_width: assigns.max_bar_width
    }

    assigns = assign(assigns, config_json: encode_config!(config))

    ~H"""
    <div data-chart-child="bar" data-chart-config={@config_json} style="display:none" {@rest}></div>
    """
  end

  @doc """
  Adds a line series.

  ## Examples

      <.container id="my-chart">
        <.x_axis labels={["00:00", "06:00", "12:00", "18:00"]} />
        <.line
          curve="spline"
          series={[
            %{label: "Server A", data: [42, 45, 43, 46], suffix: "°C"}
          ]}
        />
      </.container>
  """
  attr :series, :list, required: true
  attr :curve, :string, values: ["linear", "stepped", "spline"], default: "linear"
  attr :area, :boolean, default: false
  attr :time, :boolean, default: false
  attr :labels, :list, default: []
  attr :x, :list, default: nil
  attr :rest, :global

  def line(assigns) do
    {series_data, series_config} = normalize_series!(assigns.series, "ComposeChart.line")
    expected_points = series_data |> List.first([]) |> length()

    if expected_points > 0,
      do: validate_series_lengths!(series_data, expected_points, "ComposeChart.line")

    config = %{
      series: series_config,
      series_data: series_data,
      curve: assigns.curve,
      area: assigns.area,
      time: assigns.time,
      labels: assigns.labels
    }

    config =
      if assigns.x do
        validate_x_length!(assigns.x, expected_points, "ComposeChart.line")
        Map.put(config, :x, assigns.x)
      else
        config
      end

    assigns = assign(assigns, config_json: encode_config!(config))

    ~H"""
    <div data-chart-child="line" data-chart-config={@config_json} style="display:none" {@rest}></div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

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

  defp validate_x_length!(x_values, expected_points, component_name) when is_list(x_values) do
    if length(x_values) != expected_points do
      raise ArgumentError,
            "#{component_name} expects x to have #{expected_points} points"
    end
  end

  defp validate_x_length!(_x_values, _expected_points, component_name) do
    raise ArgumentError, "#{component_name} expects x to be a list"
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
