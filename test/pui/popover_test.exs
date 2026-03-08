defmodule PUI.PopoverTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Popover

  describe "base popover with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.base id="test" variant="unstyled" phx-hook="PUI.Popover">
          <:trigger class="my-trigger">Click</:trigger>
          <:popup class="my-popup">Content</:popup>
        </.base>
        """)

      assert html =~ "my-trigger"
      assert html =~ "my-popup"
    end

    test "preserves ARIA attributes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.base id="test" variant="unstyled" phx-hook="PUI.Popover">
          <:trigger>Click</:trigger>
          <:popup>Content</:popup>
        </.base>
        """)

      assert html =~ ~s(aria-haspopup="listbox")
      assert html =~ ~s(role="listbox")
    end
  end

  describe "tooltip with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tooltip variant="unstyled" class="my-tooltip">
          <span>Hover me</span>
          <:tooltip>Tooltip text</:tooltip>
        </.tooltip>
        """)

      assert html =~ "my-tooltip"
      refute html =~ "bg-foreground"
    end

    test "hides arrow in unstyled mode" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tooltip variant="unstyled">
          <span>Hover</span>
          <:tooltip>Text</:tooltip>
        </.tooltip>
        """)

      refute html =~ "data-arrow"
    end
  end
end
