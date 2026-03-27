defmodule AppWeb.DialogFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dialogs open and close with accessible labeling", %{session: session} do
    session
    |> visit("/__test__/components/dialog")
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
    |> click(button("Open Dialog"))
    |> assert_has(css("#server-dialog-content[role='dialog'][aria-label='Harness dialog']"))
    |> click(button("Close Dialog"))
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
  end

  feature "dialog select can reopen after changing the selected category", %{session: session} do
    session
    |> visit("/__test__/components/dialog")
    |> click(button("Open Dialog"))
    |> click(css("#dialog-select-trigger"))
    |> click(css("#dialog-select-listbox [role='option']", text: "Gamma"))
    |> assert_has(css("#dialog-select-trigger", text: "Gamma"))
    |> click(css("#dialog-select-trigger"))
    |> assert_has(css("#dialog-select-listbox[aria-hidden='false']"))
    |> assert_has(css("#dialog-select-listbox [role='option']", text: "Gamma"))
  end
end
