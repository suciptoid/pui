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

  test "select primitive renders selected values and listbox parts" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Select.Primitive.value placeholder="Choose" class="value">
        Selected food
      </PUI.Select.Primitive.value>
      <PUI.Select.Primitive.content id="food-listbox" trigger_id="food-trigger">
        <PUI.Select.Primitive.item id="apple" value="apple" data-active="true">
          Apple
        </PUI.Select.Primitive.item>
      </PUI.Select.Primitive.content>
      """)

    assert html =~ "Selected food"
    assert html =~ ~s(class="value")
    assert html =~ ~s(role="listbox")
    assert html =~ ~s(aria-labelledby="food-trigger")
    assert html =~ ~s(id="apple")
    assert html =~ ~s(data-value="apple")
    assert html =~ "Apple"
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

  test "primitive options expose the active-state hook contract without styles" do
    import PUI.Select.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.item value="design">Design</.item>|)

    assert html =~ ~s(role="option")
    assert html =~ ~s(tabindex="-1")
    refute html =~ "bg-accent"
  end

  test "primitive dropdown items leave width and focus presentation to the application" do
    import PUI.Dropdown.Primitive
    assigns = %{}
    html = rendered_to_string(~H|<.item>Profile</.item>|)

    assert html =~ ~s(role="menuitem")
    refute html =~ "w-full"
    refute html =~ "focus-visible"
  end

  test "dropdown primitive forwards popover and menu item variants" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Dropdown.Primitive.root id="actions" placement="top-end" trigger="hover">
        <PUI.Dropdown.Primitive.trigger id="actions-trigger" controls="actions-menu">
          Actions
        </PUI.Dropdown.Primitive.trigger>
        <PUI.Dropdown.Primitive.content id="actions-menu">
          <PUI.Dropdown.Primitive.item href="/profile">Profile</PUI.Dropdown.Primitive.item>
          <PUI.Dropdown.Primitive.item phx-click="delete">Delete</PUI.Dropdown.Primitive.item>
          <PUI.Dropdown.Primitive.separator />
        </PUI.Dropdown.Primitive.content>
      </PUI.Dropdown.Primitive.root>
      """)

    assert html =~ ~s(phx-hook="PUI.Popover")
    assert html =~ ~s(data-placement="top-end")
    assert html =~ ~s(data-trigger="hover")
    assert html =~ ~s(aria-haspopup="menu")
    assert html =~ ~s(aria-controls="actions-menu")
    assert html =~ ~s(role="menu")
    assert html =~ ~s(href="/profile")
    assert html =~ ~s(phx-click="delete")
    assert html =~ ~s(role="separator")
  end

  test "date picker primitive exposes its hook, trigger, popup, and input contracts" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.DatePicker.Primitive.root id="birthday-picker" data-testid="picker">
        <PUI.DatePicker.Primitive.trigger id="birthday-trigger" controls="birthday-content">
          Choose date
        </PUI.DatePicker.Primitive.trigger>
        <PUI.DatePicker.Primitive.content id="birthday-content">
          Calendar
        </PUI.DatePicker.Primitive.content>
        <PUI.DatePicker.Primitive.input
          id="birthday-input"
          name="birthday"
          value="2026-08-06"
        />
      </PUI.DatePicker.Primitive.root>
      """)

    assert html =~ ~s(phx-hook="PUI.DatePicker")
    assert html =~ ~s(data-testid="picker")
    assert html =~ ~s(aria-haspopup="dialog")
    assert html =~ ~s(aria-controls="birthday-content")
    assert html =~ ~s(role="dialog")
    assert html =~ ~s(data-floating-strategy="absolute")
    assert html =~ ~s(name="birthday")
    assert html =~ ~s(value="2026-08-06")
  end

  test "sidebar primitive renders collapsed state and toggle semantics" do
    assigns = %{collapsed: true}

    html =
      rendered_to_string(~H"""
      <PUI.Layout.Sidebar.Primitive.root id="app-sidebar" collapsed={@collapsed}>
        Navigation
      </PUI.Layout.Sidebar.Primitive.root>
      <PUI.Layout.Sidebar.Primitive.toggle id="sidebar-toggle" aria-label="Toggle sidebar">
        Toggle
      </PUI.Layout.Sidebar.Primitive.toggle>
      """)

    assert html =~ ~s(data-collapsed="true")
    assert html =~ ~s(data-shell="app-sidebar")
    assert html =~ ~s(phx-hook="PUI.Sidebar")
    assert html =~ ~s(id="sidebar-toggle")
    assert html =~ ~s(aria-label="Toggle sidebar")
    assert html =~ "Navigation"
  end

  test "tabs primitive renders orientation and selected state contracts" do
    assigns = %{selected: true, disabled: true}

    html =
      rendered_to_string(~H"""
      <PUI.Tabs.Primitive.root
        id="settings"
        orientation="vertical"
        activation_mode="automatic"
        client_controlled={false}
      >
        <PUI.Tabs.Primitive.list orientation="vertical">
          <PUI.Tabs.Primitive.trigger
            id="profile-tab"
            value="profile"
            selected={@selected}
            controls="profile-panel"
          >
            Profile
          </PUI.Tabs.Primitive.trigger>
          <PUI.Tabs.Primitive.trigger id="billing-tab" value="billing" disabled={@disabled}>
            Billing
          </PUI.Tabs.Primitive.trigger>
        </PUI.Tabs.Primitive.list>
        <PUI.Tabs.Primitive.panel
          id="profile-panel"
          value="profile"
          selected={@selected}
          labelledby="profile-tab"
        >
          Profile content
        </PUI.Tabs.Primitive.panel>
      </PUI.Tabs.Primitive.root>
      """)

    assert html =~ ~s(phx-hook="PUI.Tabs")
    assert html =~ ~s(data-orientation="vertical")
    assert html =~ ~s(data-activation-mode="automatic")
    assert html =~ ~s(data-client-controlled="false")
    assert html =~ ~s(role="tablist")
    assert html =~ ~s(aria-selected="true")
    assert html =~ ~s(aria-controls="profile-panel")
    assert html =~ ~s(data-disabled="true")
    assert html =~ ~s(role="tabpanel")
    assert html =~ ~s(aria-labelledby="profile-tab")
    assert html =~ "Profile content"
  end
end
