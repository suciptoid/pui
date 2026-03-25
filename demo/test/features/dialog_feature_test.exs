defmodule AppWeb.DialogFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dialogs open and close with accessible labeling", %{session: session} do
    session
    |> visit("/dialog")
    |> assert_has(css("button", text: "Open Dialog"))
    |> assert_has(
      css("#x-content[role='dialog'][aria-label='Edit profile dialog'][hidden]", visible: false)
    )
    |> assert_has(
      css("#destroy-content[role='dialog'][aria-label='Destroy server dialog'][hidden]",
        visible: false
      )
    )
  end
end
