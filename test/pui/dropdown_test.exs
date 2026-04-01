defmodule PUI.DropdownTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Dropdown

  describe "menu_button with variant='unstyled'" do
    test "renders unstyled button without default classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.menu_button variant="unstyled" class="custom-btn">
          Open
          <:item class="custom-item">Profile</:item>
        </.menu_button>
        """)

      assert html =~ "custom-btn"
      assert html =~ "custom-item"
      refute html =~ "bg-secondary"
    end

    test "preserves ARIA attributes in unstyled mode" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.menu_button variant="unstyled">
          Open
          <:item>Profile</:item>
        </.menu_button>
        """)

      assert html =~ ~s(aria-haspopup="menu")
      assert html =~ ~s(role="menu")
      assert html =~ ~s(role="menuitem")
    end

    test "menu_content accepts custom class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.menu_button variant="unstyled" content_class="my-menu">
          Open
          <:item>Profile</:item>
        </.menu_button>
        """)

      assert html =~ "my-menu"
    end
  end

  describe "menu_item layout" do
    test "default menu items fill the menu width" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.menu_button>
          Open
          <:item>Profile</:item>
        </.menu_button>
        """)

      assert html =~ ~s(role="menuitem")
      assert html =~ "flex w-full"
      assert html =~ "text-left"
    end
  end
end
