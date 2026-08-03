defmodule PUI.PrimitiveTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "select primitive keeps hook and semantics without default classes" do
    import PUI.Select.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.root id="food">
  <.trigger id="food-trigger" listbox_id="food-listbox">Food</.trigger>
</.root>|)
    assert html =~ ~s(phx-hook="PUI.Select")
    assert html =~ ~s(aria-haspopup="listbox")
    refute html =~ "border-input"
  end

  test "dialog primitive keeps modal semantics without default classes" do
    import PUI.Dialog.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.content id="dialog-content">Body</.content>|)
    assert html =~ ~s(role="dialog")
    refute html =~ "bg-background"
  end
end
