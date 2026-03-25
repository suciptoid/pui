defmodule AppWeb.FeedbackFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "alert, toast, and container demos render expected accessible UI", %{session: session} do
    session
    |> visit("/alert")
    |> assert_has(css("[role='status']", text: "Your changes have been saved"))
    |> assert_has(css("[role='alert']", text: "Unable to process your request"))

    session
    |> visit("/toast")
    |> assert_has(css("button", text: "Use send_flash"))
    |> assert_has(css("button", text: "Customize Flash"))

    session
    |> visit("/container")
    |> assert_has(css("p", text: "john@example.com"))
    |> assert_has(css("button", text: "Save Changes"))
  end
end
