defmodule PUI.PrimitiveTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "select primitive keeps hook, value, and label parts without default classes" do
    import PUI.Select.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.root id="food">
  <.input id="food-value" name="food" />
  <.trigger id="food-trigger" listbox_id="food-listbox">
    <.value placeholder="Choose food" />
  </.trigger>
</.root>|)
    assert html =~ ~s(phx-hook="PUI.Select")
    assert html =~ ~s(aria-haspopup="listbox")
    assert html =~ ~s(data-pui="select-value")
    assert html =~ ~s(data-pui="selected-label")
    assert html =~ "Choose food"
    refute html =~ "border-input"
  end

  test "select primitive value falls back to the placeholder" do
    import PUI.Select.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.value placeholder="Pick a food" />|)
    assert html =~ "Pick a food"
    assert html =~ ~s(data-placeholder="Pick a food")
  end

  test "dialog primitive keeps modal semantics without default classes" do
    import PUI.Dialog.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.content id="dialog-content">Body</.content>|)
    assert html =~ ~s(role="dialog")
    refute html =~ "bg-background"
  end

  test "dialog backdrop cancels the root it is told about, not a derived id" do
    import PUI.Dialog.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.backdrop id="scrim" root_id="confirm" />|)
    assert html =~ "&quot;#confirm&quot;"
    refute html =~ "#scrim"
  end

  test "dialog backdrop derives the root id from the default naming convention" do
    import PUI.Dialog.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.backdrop id="confirm-backdrop" />|)
    assert html =~ "&quot;#confirm&quot;"
  end

  test "dropdown primitive menu carries menu semantics" do
    import PUI.Dropdown.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.content id="menu">Body</.content>|)
    assert html =~ ~s(role="menu")
    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ ~s(tabindex="-1")
    refute html =~ "bg-popover"
  end
end
