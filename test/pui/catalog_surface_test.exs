defmodule PUI.CatalogSurfaceTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "button groups expose group and separator semantics" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.ButtonGroup.button_group aria-label="Actions">
        <button type="button">Copy</button>
        <PUI.ButtonGroup.button_group_separator />
        <button type="button">Paste</button>
      </PUI.ButtonGroup.button_group>
      """)

    assert html =~ ~s(role="group")
    assert html =~ ~s(aria-label="Actions")
    assert html =~ ~s(role="separator")
  end

  test "tabs render linked roles and active state" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Tabs.tabs id="settings-tabs" default_value="profile">
        <:trigger value="profile">Profile</:trigger>
        <:trigger value="billing">Billing</:trigger>
        <:content value="profile">Profile content</:content>
        <:content value="billing">Billing content</:content>
      </PUI.Tabs.tabs>
      """)

    assert html =~ ~s(id="settings-tabs")
    assert html =~ ~s(role="tablist")
    assert html =~ ~s(role="tab")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(role="tabpanel")
    assert html =~ "Profile content"
  end

  test "loading exposes the configured delay and hook" do
    assigns = %{}
    html = rendered_to_string(~H|<PUI.Loading.topbar delay={100} class="custom-bar" />|)

    assert html =~ ~s(phx-hook="PUI.LoadingBar")
    assert html =~ ~s(data-delay="100")
    assert html =~ "custom-bar"
  end

  test "menu button renders a menu trigger and popup" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.MenuButton.button id="actions-menu">
        <:button>Actions</:button>
        <:popup>
          <PUI.MenuButton.menu_item>Save</PUI.MenuButton.menu_item>
        </:popup>
      </PUI.MenuButton.button>
      """)

    assert html =~ ~s(id="actions-menu-trigger")
    assert html =~ ~s(role="menu")
    assert html =~ ~s(role="menuitem")
    assert html =~ "Save"
  end

  test "flash group renders Phoenix flash keys" do
    assigns = %{flash: %{success: "Saved"}}

    html =
      rendered_to_string(~H|<PUI.Flash.flash_group flash={@flash} />|)

    assert html =~ "Saved"
    assert html =~ ~s(role="alert")
  end
end
