defmodule AppWeb.SelectFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "select components support labeling, search, and selection", %{session: session} do
    session
    |> visit("/__test__/components/select")
    |> assert_has(css("label[for='harness-select-trigger']"))
    |> assert_has(
      css("#harness-select-trigger[role='combobox'][aria-controls='harness-select-listbox']")
    )
    |> assert_has(css("#harness-select-trigger", text: "Beta"))
    |> assert_has(css("#harness-select [role='searchbox']", visible: false))
    |> assert_has(css("#select-value", text: "Selected: beta"))
  end
end
