defmodule AppWeb.SelectFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "select components support labeling, search, and selection", %{session: session} do
    session
    |> visit("/select")
    |> assert_has(css("label[for='select-basic-trigger']"))
    |> assert_has(
      css("#select-basic-trigger[role='combobox'][aria-controls='select-basic-listbox']")
    )
    |> assert_has(
      css("#select-basic-listbox[role='listbox'][aria-hidden='true']", visible: false)
    )
    |> assert_has(css("#select-searchable [role='searchbox']", visible: false))
  end
end
