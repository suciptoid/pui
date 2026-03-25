defmodule AppWeb.DropdownFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dropdown menus open with menu semantics", %{session: session} do
    session
    |> visit("/dropdown")
    |> assert_has(css("#dropdown-account-trigger[aria-controls='dropdown-account-listbox']"))
    |> assert_has(
      css("#dropdown-account-listbox[role='menu'][aria-hidden='true']", visible: false)
    )
    |> assert_has(css("#dropdown-account-listbox [role='menuitem']", visible: false, count: 3))
  end
end
