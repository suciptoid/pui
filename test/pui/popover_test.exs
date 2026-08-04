defmodule PUI.PopoverTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Popover

  describe "base/1" do
    test "renders slot classes on the trigger and popup" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.base id="test" phx-hook="PUI.Popover">
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
        <.base id="test" phx-hook="PUI.Popover">
          <:trigger>Click</:trigger>
          <:popup>Content</:popup>
        </.base>
        """)

      assert html =~ ~s(aria-haspopup="listbox")
      assert html =~ ~s(aria-controls="test-listbox")
      assert html =~ ~s(role="listbox")
    end
  end

  describe "tooltip/1" do
    test "appends class to the default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tooltip class="my-tooltip">
          <span>Hover me</span>
          <:tooltip>Tooltip text</:tooltip>
        </.tooltip>
        """)

      assert html =~ "my-tooltip"
      assert html =~ "bg-foreground"
      assert html =~ "data-arrow"
    end

    test "light variant swaps the surface colors" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tooltip variant="light">
          <span>Hover</span>
          <:tooltip>Text</:tooltip>
        </.tooltip>
        """)

      assert html =~ "bg-white"
      refute html =~ "bg-foreground text-background"
    end
  end

  describe "PUI.Tooltip.Primitive" do
    test "keeps tooltip semantics without default classes" do
      import PUI.Tooltip.Primitive
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.root id="tip" placement="right">
          <button type="button">Hover</button>
          <.content id="tip-tooltip" class="my-tip">Text</.content>
        </.root>
        """)

      assert html =~ ~s(phx-hook="PUI.Tooltip")
      assert html =~ ~s(role="tooltip")
      assert html =~ ~s(aria-hidden="true")
      assert html =~ "my-tip"
      refute html =~ "bg-foreground"
      refute html =~ "data-arrow"
    end
  end
end
