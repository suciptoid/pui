defmodule AppWeb.DocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "button docs render inline demo content inside the article body", %{session: session} do
    session
    |> visit("/docs/button")
    |> assert_has(css("article", text: "Interactive Playground"))
    |> assert_has(css("article", text: "Rendered Variants"))
    |> assert_has(css("article", text: "Rendered Sizes"))
  end

  feature "popover docs demo opens the basic popover", %{session: session} do
    session
    |> visit("/docs/popover")
    |> click(css("#demo-popover-trigger"))
    |> assert_has(css("#demo-popover-listbox[aria-hidden='false']"))
    |> assert_has(css("#demo-popover-listbox", text: "Popover Title"))
  end

  feature "flash docs expose position controls", %{session: session} do
    session
    |> visit("/docs/flash")
    |> assert_has(css("button[phx-value-position='top-left']"))
    |> assert_has(css("button[phx-value-position='bottom-right']"))
    |> assert_has(css("#send-toast", text: "Position: top-right"))
  end

  feature "input docs demonstrate field validation errors", %{session: session} do
    session
    |> visit("/docs/input")
    |> fill_in(css("#demo_name"), with: "")
    |> assert_has(css("p", text: "Please enter your full name."))
    |> assert_has(css("p", text: "Please enter a valid email address."))
  end
end
