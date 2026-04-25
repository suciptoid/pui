defmodule AppWeb.LayoutAppFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "layout app demo renders a full-page shell", %{session: session} do
    session
    |> visit("/demo/layout-app")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("#demo-app-shell[data-collapsed='false']"))
    |> assert_has(css("h1", text: "App layout shell for Phoenix LiveView"))
  end
end
