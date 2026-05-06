defmodule PUI.ComposeChartTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.ComposeChart

  describe "container" do
    test "renders the ComposeChart hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="test-compose" height={280}>
          <.bar series={[%{label: "A", data: [1, 2, 3]}]} />
        </.container>
        """)

      assert html =~ ~s(id="test-compose")
      assert html =~ ~s(phx-hook="PUI.ComposeChart")
      assert html =~ ~s(style="height: 280px")
    end

    test "renders custom classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="custom-class" class="my-chart">
          <.bar series={[%{label: "A", data: [1, 2, 3]}]} />
        </.container>
        """)

      assert html =~ ~s(my-chart)
    end
  end

  describe "bar" do
    test "renders bar child with series config" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="bar-test">
          <.x_axis categories={["Jan", "Feb", "Mar"]} />
          <.tooltip />
          <.bar series={[
            %{label: "Revenue", data: [10.0, 12.5, 14.2], suffix: " jt"}
          ]} />
        </.container>
        """)

      assert html =~ ~s(data-chart-child="bar")
      assert html =~ ~s(data-chart-child="x-axis")
      assert html =~ ~s(data-chart-child="tooltip")
      assert html =~ ~s(&quot;categories&quot;:[&quot;Jan&quot;,&quot;Feb&quot;,&quot;Mar&quot;])
      assert html =~ ~s(&quot;suffix&quot;:&quot; jt&quot;)
      assert html =~ ~s(&quot;series_data&quot;:[[10.0,12.5,14.2]])
    end

    test "raises on mismatched series" do
      message = "ComposeChart.bar expects every series data list to have 2 points"
      assigns = %{}

      assert_raise ArgumentError, message, fn ->
        rendered_to_string(~H"""
        <.container id="bar-invalid">
          <.bar series={[
            %{label: "A", data: [1, 2]},
            %{label: "B", data: [1, 2, 3]}
          ]} />
        </.container>
        """)
      end
    end
  end

  describe "line" do
    test "renders line child with series config" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="line-test">
          <.x_axis labels={["00:00", "06:00", "12:00"]} />
          <.line
            curve="stepped"
            series={[
              %{label: "Server A", data: [42, 44, 43], suffix: "°C"}
            ]}
          />
        </.container>
        """)

      assert html =~ ~s(data-chart-child="line")
      assert html =~ ~s(data-chart-child="x-axis")
      assert html =~ ~s(&quot;curve&quot;:&quot;stepped&quot;)

      assert html =~
               ~s(&quot;labels&quot;:[&quot;00:00&quot;,&quot;06:00&quot;,&quot;12:00&quot;])

      assert html =~ ~s(&quot;series_data&quot;:[[42,44,43]])
    end

    test "raises on mismatched x values length" do
      message = "ComposeChart.line expects x to have 3 points"
      assigns = %{}

      assert_raise ArgumentError, message, fn ->
        rendered_to_string(~H"""
        <.container id="line-invalid-x">
          <.line
            x={[1, 2]}
            series={[
              %{label: "Server A", data: [42, 44, 43]}
            ]}
          />
        </.container>
        """)
      end
    end
  end

  describe "legend" do
    test "renders legend child" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="legend-test">
          <.legend />
          <.bar series={[%{label: "A", data: [1, 2, 3]}]} />
        </.container>
        """)

      assert html =~ ~s(data-chart-child="legend")
    end
  end

  describe "y_axis" do
    test "renders y-axis child" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="yaxis-test">
          <.y_axis />
          <.bar series={[%{label: "A", data: [1, 2, 3]}]} />
        </.container>
        """)

      assert html =~ ~s(data-chart-child="y-axis")
    end
  end

  describe "inner_block" do
    test "renders arbitrary HTML alongside chart children" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.container id="block-test">
          <div class="custom-header">My Chart</div>
          <.bar series={[%{label: "A", data: [1, 2, 3]}]} />
        </.container>
        """)

      assert html =~ ~s(class="custom-header")
      assert html =~ ~s(My Chart)
      assert html =~ ~s(data-chart-child="bar")
    end
  end
end
