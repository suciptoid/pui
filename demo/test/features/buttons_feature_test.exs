defmodule AppWeb.ButtonsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "buttons page renders interactive and accessible examples", %{session: session} do
    session
    |> visit("/buttons")
    |> assert_has(css("#button-preview"))
    |> assert_has(css("button[aria-label='default favorite button']"))
    |> assert_has(css("a", text: "Patch Navigation"))
  end
end
