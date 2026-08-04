defmodule PUI.DropdownTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Dropdown

  test "styled dropdown composes the primitive hook contract" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_button id="menu"><:item>Profile</:item>Open</.menu_button>|)

    assert html =~ ~s(phx-hook="PUI.Popover")
    assert html =~ ~s(role="menu")
  end

  test "trigger does not submit an enclosing form and reports collapsed state" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_button id="menu"><:item>Profile</:item>Open</.menu_button>|)

    assert html =~ ~s(type="button")
    assert html =~ ~s(aria-haspopup="menu")
    assert html =~ ~s(aria-expanded="false")
    assert html =~ ~s(aria-controls="menu-menu")
  end

  test "menu keeps orientation and focus semantics" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_button id="menu"><:item>Profile</:item>Open</.menu_button>|)

    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ ~s(tabindex="-1")
  end

  test "item slot forwards click bindings and shortcuts" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_button id="menu">
  <:item phx-click="pick" phx-value-action="archive" shortcut="⌘A">Archive</:item>
  Open
</.menu_button>|)

    assert html =~ ~s(phx-click="pick")
    assert html =~ ~s(phx-value-action="archive")
    assert html =~ "⌘A"
  end

  test "menu_item accepts name and value for form submission" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_item name="action" value="delete">Delete</.menu_item>|)

    assert html =~ ~s(name="action")
    assert html =~ ~s(value="delete")
  end

  test "menu_item matches keyboard selection to hover styling" do
    assigns = %{}

    html = rendered_to_string(~H|<.menu_item>Profile</.menu_item>|)

    assert html =~ "hover:bg-accent"
    assert html =~ "aria-selected:bg-accent"
  end

  test "menu_content and menu_shortcut remain public parts" do
    assigns = %{}

    html =
      rendered_to_string(~H|<.menu_content id="menu-menu">
  <.menu_shortcut>⌘K</.menu_shortcut>
</.menu_content>|)

    assert html =~ ~s(role="menu")
    assert html =~ "⌘K"
  end
end
