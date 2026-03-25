defmodule AppWeb.FeedbackFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "alert, toast, and container demos render expected accessible UI", %{session: session} do
    session
    |> visit("/__test__/components/alert")
    |> assert_has(css("#status-alert[role='status']", text: "Changes persisted successfully."))
    |> assert_has(css("#destructive-alert[role='alert']", text: "Unable to save changes."))

    session
    |> visit("/__test__/components/flash")
    |> click(button("Send Flash"))
    |> assert_has(css("[role='alert']", visible: false, count: 1))

    session
    |> visit("/__test__/components/container")
    |> assert_has(css("#profile-card"))
    |> assert_has(css("#profile-email", text: "john@example.com"))
    |> assert_has(css("#save-profile", text: "Save Changes"))
  end
end
