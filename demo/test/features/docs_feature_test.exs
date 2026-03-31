defmodule AppWeb.DocsFeatureTest do
  use AppWeb.FeatureCase, async: false

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
