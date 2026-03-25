defmodule AppWeb.PopoverFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "popovers and tooltips expose accessible relationships", %{session: session} do
    session
    |> visit("/__test__/components/popover")
    |> assert_has(css("#harness-tooltip-tooltip[role='tooltip']", visible: false))
    |> assert_has(css("#tooltip-trigger"))
    |> assert_has(css("#popover-trigger[aria-haspopup='menu']"))
    |> assert_has(
      css("#harness-popover-listbox[role='listbox'][aria-hidden='true']", visible: false)
    )
    |> assert_has(css("#popover-count", visible: false))
  end
end
