defmodule PUI.ChartTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Chart

  describe "chart" do
    test "renders the base chart hook and serialized config" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.chart
          id="test-chart"
          height={280}
          config={
            %{
              data: [[1, 2, 3], [12, 18, 20]],
              series: [%{label: "Traffic"}]
            }
          }
        />
        """)

      assert html =~ ~s(id="test-chart")
      assert html =~ ~s(phx-hook="PUI.Chart")
      assert html =~ ~s(style="height: 280px")
      assert html =~ ~s(&quot;label&quot;:&quot;Traffic&quot;)
    end

    test "uses a custom colocated hook without rendering the default hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.chart
          id="custom-chart"
          phx-hook=".MixedChart"
          config={
            %{
              data: [[1, 2, 3], [12, 18, 20]],
              series: [%{label: "Traffic"}]
            }
          }
        />
        """)

      assert html =~ ~s(phx-hook="PUI.ChartTest.MixedChart")
      refute html =~ ~s(phx-hook="PUI.Chart")
    end
  end

  describe "bar_chart" do
    test "renders the preconfigured bar chart hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.bar_chart
          id="bar-chart"
          categories={["Jan", "Feb", "Mar"]}
          series={[
            %{label: "Revenue", data: [10.0, 12.5, 14.2], suffix: " jt"}
          ]}
        />
        """)

      assert html =~ ~s(phx-hook="PUI.BarChart")
      assert html =~ ~s(&quot;preset&quot;:&quot;bar&quot;)
      assert html =~ ~s(&quot;categories&quot;:[&quot;Jan&quot;,&quot;Feb&quot;,&quot;Mar&quot;])
      assert html =~ ~s(&quot;suffix&quot;:&quot; jt&quot;)
      assert html =~ ~s(&quot;radius&quot;:0.1)
    end

    test "raises on mismatched category lengths" do
      message = "bar_chart expects every series data list to have 2 points"
      assigns = %{}

      assert_raise ArgumentError, message, fn ->
        rendered_to_string(~H"""
        <.bar_chart
          id="invalid-bar-chart"
          categories={["Jan", "Feb"]}
          series={[
            %{label: "Revenue", data: [10.0, 12.5, 14.2]}
          ]}
        />
        """)
      end
    end
  end

  describe "line_chart" do
    test "renders the preconfigured line chart hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.line_chart
          id="line-chart"
          curve="stepped"
          labels={["00:00", "06:00", "12:00"]}
          series={[
            %{label: "Server A", data: [42, 44, 43], suffix: "°C"}
          ]}
        />
        """)

      assert html =~ ~s(phx-hook="PUI.LineChart")
      assert html =~ ~s(&quot;preset&quot;:&quot;line&quot;)
      assert html =~ ~s(&quot;curve&quot;:&quot;stepped&quot;)

      assert html =~
               ~s(&quot;labels&quot;:[&quot;00:00&quot;,&quot;06:00&quot;,&quot;12:00&quot;])
    end

    test "raises on mismatched x values" do
      message = "expected line_chart x values length to match each series length"
      assigns = %{}

      assert_raise ArgumentError, message, fn ->
        rendered_to_string(~H"""
        <.line_chart
          id="invalid-line-chart"
          x={[1, 2]}
          series={[
            %{label: "Server A", data: [42, 44, 43]}
          ]}
        />
        """)
      end
    end

    test "renders sparklines with the dedicated sparkline hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.line_chart
          id="sparkline-chart"
          sparkline={true}
          series={[
            %{data: [12, 18, 15, 20]}
          ]}
        />
        """)

      assert html =~ ~s(phx-hook="PUI.SparklineChart")
      assert html =~ ~s(style="height: 56px")
      assert html =~ ~s(&quot;preset&quot;:&quot;line&quot;)
    end
  end
end
