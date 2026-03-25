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
end
