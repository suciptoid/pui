defmodule AppWeb.DatePickerDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "date picker docs render the new demos and sidebar link", %{session: session} do
    session
    |> visit("/docs/date-picker")
    |> assert_has(css("h1", text: "Date Picker"))
    |> assert_has(css("a[href='/docs/date-picker']", text: "Date Picker"))
    |> assert_has(css("#date-picker-basic-demo"))
    |> assert_has(css("#date-picker-bounds-demo"))
    |> assert_has(css("#date-picker-footer-demo"))
  end
end
