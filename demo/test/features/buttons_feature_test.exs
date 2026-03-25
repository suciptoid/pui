defmodule AppWeb.ButtonsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "buttons page renders interactive and accessible examples", %{session: session} do
    session
    |> visit("/__test__/components/button")
    |> click(button("Primary Action"))
    |> assert_has(css("#button-count", text: "Clicked: 1"))
    |> assert_has(css("#button-link"))
    |> assert_has(css("#button-icon[aria-label='Favorite item']"))
  end
end
