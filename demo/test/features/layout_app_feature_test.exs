defmodule AppWeb.LayoutAppFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "layout app demo renders a full-page shell", %{session: session} do
    session
    |> visit("/demo/layout/overview")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("#demo-app-shell[data-collapsed='false']"))
    |> assert_has(css("h1", text: "Overview"))
  end
end
