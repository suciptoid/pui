defmodule AppWeb.PopoverFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "popovers and tooltips expose accessible relationships", %{session: session} do
    session
    |> visit("/popover")
    |> assert_has(css("#tooltip-left [role='tooltip']", visible: false))
    |> assert_has(css("#demo-popover-base button[aria-haspopup='menu']"))
    |> assert_has(
      css("#demo-popover-base-listbox[role='listbox'][aria-hidden='true']", visible: false)
    )
  end
end
