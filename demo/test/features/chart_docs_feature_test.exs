defmodule AppWeb.ChartDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "chart docs render demos and lifecycle controls", %{session: session} do
    session
    |> visit("/docs/chart")
    |> assert_has(css("h1", text: "Chart"))
    |> assert_has(css("a[href='/docs/chart']", text: "Chart"))
    |> assert_has(css("#chart-base-demo"))
    |> assert_has(css("#chart-bar-demo"))
    |> assert_has(css("#chart-line-demo"))
    |> assert_has(css("button[phx-value-curve='linear']"))
    |> assert_has(css("#chart-reseed", text: "Refresh dataset"))
  end
end
