defmodule PUI.LayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Layout

  test "app_layout renders sidebar, header, and body content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.app_layout id="shell">
        <:sidebar>
          <aside>Sidebar</aside>
        </:sidebar>
        <:header>
          <header>Header</header>
        </:header>
        Body
      </.app_layout>
      """)

    assert html =~ ~s(id="shell")
    assert html =~ ~s(data-collapsed="false")
    assert html =~ "Sidebar"
    assert html =~ "Header"
    assert html =~ "Body"
  end

  test "app_layout can render the initial collapsed state" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.app_layout id="shell" collapsed>
        <:sidebar>
          <aside>Sidebar</aside>
        </:sidebar>
        Body
      </.app_layout>
      """)

    assert html =~ ~s(data-collapsed="true")
  end

  test "sidebar renders header, body, footer, and configurable widths" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.sidebar
        expanded_width_class="w-64"
        collapsed_width_class="group-data-[collapsed=true]/pui-layout:w-12"
      >
        <:header>Brand</:header>
        Navigation
        <:footer>Account</:footer>
      </.sidebar>
      """)

    assert html =~ "Brand"
    assert html =~ "Navigation"
    assert html =~ "Account"
    assert html =~ "w-64"
    assert html =~ "group-data-[collapsed=true]/pui-layout:w-12"
  end

  test "sidebar_menu_item renders link metadata" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.sidebar_menu_item title="Overview" icon="hero-home" href="/overview" current>
        <:trailing><span>3</span></:trailing>
      </.sidebar_menu_item>
      """)

    assert html =~ ~s(id="sidebar-item-overview")
    assert html =~ ~s(href="/overview")
    assert html =~ ~s(title="Overview")
    assert html =~ ~s(phx-hook="PUI.Tooltip")
    assert html =~ "fixed hidden group-data-[collapsed=true]/pui-layout:block"
    assert html =~ "hero-home"
    assert html =~ "3"
  end

  test "sidebar_menu_item renders collapsible submenu metadata" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.sidebar_menu_item title="Components" icon="hero-squares-2x2" collapsible expanded>
        <:subitem><span>Button</span></:subitem>
      </.sidebar_menu_item>
      """)

    assert html =~ ~s(phx-hook="PUI.Sidebar")
    assert html =~ ~s(aria-expanded="true")
    assert html =~ ~s(aria-controls="sidebar-item-components-submenu")
    assert html =~ ~s(id="sidebar-item-components-submenu")
    assert html =~ "Button"
  end

  test "content_header toggles the shell collapse attribute" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.content_header shell_id="shell" title="Docs" breadcrumb_current="Layout" />
      """)

    assert html =~ ~s(id="shell-sidebar-collapse-toggle")
    assert html =~ "Toggle sidebar"
    assert html =~ "Docs"
    assert html =~ "Layout"
  end
end
