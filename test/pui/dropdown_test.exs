defmodule PUI.DropdownTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Dropdown

  test "styled dropdown composes the primitive hook contract" do
    assigns = %{}
    html = rendered_to_string(~H|<.menu_button id="menu"><:item>Profile</:item>Open</.menu_button>|)
    assert html =~ ~s(phx-hook="PUI.Popover")
    assert html =~ ~s(role="menu")
  end
end
