defmodule AppWeb.LayoutAppFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "layout app demo renders a full-page shell", %{session: session} do
    session
    |> visit("/demo/overview")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("#demo-app-shell[data-collapsed='false']"))
    |> assert_has(css("h1", text: "Overview"))
    |> assert_has(css("#layout-overview-chart"))
    |> assert_has(css("a[href='/demo/chart']", text: "Chart"))
  end

  feature "layout chart page renders as a dedicated sidebar destination", %{session: session} do
    session
    |> visit("/demo/chart")
    |> assert_has(css("h1", text: "Chart"))
    |> assert_has(css("#layout-chart-primary"))
    |> assert_has(css("#layout-chart-secondary"))
    |> assert_has(
      css("a[href='/demo/chart'][aria-current='page'], a[href='/demo/chart']",
        text: "Chart"
      )
    )
  end
end
