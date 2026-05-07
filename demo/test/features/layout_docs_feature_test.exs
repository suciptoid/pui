defmodule AppWeb.LayoutDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "layout docs link to the dedicated app shell demo", %{session: session} do
    session
    |> visit("/docs/layout")
    |> assert_has(css("h1", text: "Layout"))
    |> assert_has(css("a[href='/demo/overview']", text: "Open app layout demo"))
  end
end
