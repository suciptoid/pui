defmodule PUI.EntryPointTest do
  use ExUnit.Case, async: true

  use PUI
  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "use PUI exposes the canonical component imports" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.button>Save</.button>
      <.badge>New</.badge>
      <.separator />
      """)

    assert html =~ "Save"
    assert html =~ "New"
    assert html =~ ~s(data-slot="separator")
  end

  test "the entry point delegates the base popover component" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.popover_base id="entry-popover">
        <:trigger>Open</:trigger>
        <:popup>Content</:popup>
      </PUI.popover_base>
      """)

    assert html =~ ~s(id="entry-popover")
    assert html =~ ~s(aria-controls="entry-popover-listbox")
    assert html =~ "Open"
    assert html =~ "Content"
  end
end
