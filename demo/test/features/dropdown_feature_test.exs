defmodule AppWeb.DropdownFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dropdown menus open with menu semantics", %{session: session} do
    session
    |> visit("/__test__/components/dropdown")
    |> assert_has(css("#harness-dropdown-trigger[aria-controls='harness-dropdown-menu']"))
    |> assert_has(css("#harness-dropdown-menu[role='menu']", visible: false))
    |> assert_has(css("#harness-dropdown-menu [role='menuitem']", count: 3, visible: false))
    |> assert_has(css("#dropdown-result", text: "none"))
  end
end
