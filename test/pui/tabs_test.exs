defmodule PUI.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Tabs

  test "supports trigger-only, line, and server-controlled tabs" do
    assigns = %{active: "billing"}

    html =
      rendered_to_string(~H"""
      <.tabs
        id="account-tabs"
        value={@active}
        client_controlled={false}
        activation_mode="automatic"
        variant="line"
        list_class="custom-list"
        panels_class="custom-panels"
      >
        <:trigger value="profile" id="profile-trigger" phx-click="select_tab">
          Profile
        </:trigger>
        <:trigger value="billing" id="billing-trigger" phx-value-tab="billing">
          Billing
        </:trigger>
        <:content value="profile" id="profile-panel">Profile content</:content>
        <:content value="billing">Billing content</:content>
      </.tabs>
      <.tabs id="trigger-only" default_value="second" variant="line">
        <:trigger value="first" disabled>First</:trigger>
        <:trigger value="second">Second</:trigger>
      </.tabs>
      """)

    assert html =~ ~s(data-value="billing")
    assert html =~ ~s(data-client-controlled="false")
    assert html =~ ~s(data-activation-mode="automatic")
    assert html =~ "custom-list"
    assert html =~ "custom-panels"
    assert html =~ ~s(id="profile-trigger")
    assert html =~ ~s(id="profile-panel")
    assert html =~ ~s(phx-click="select_tab")
    assert html =~ ~s(phx-value-tab="billing")
    assert html =~ ~s(aria-selected="true")
    assert html =~ "Profile content"
    assert html =~ "Billing content"
    assert html =~ ~s(id="trigger-only")
    assert html =~ ~s(data-disabled="true")
  end

  test "chooses the first enabled trigger when no active value is supplied" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.tabs id="fallback-tabs">
        <:trigger value="disabled" disabled>Disabled</:trigger>
        <:trigger value="first">First</:trigger>
        <:trigger value="second">Second</:trigger>
      </.tabs>
      """)

    assert html =~ ~s(data-default-value="first")
    assert html =~ ~s(data-state="active")
    assert html =~ ~s(aria-selected="true")
  end
end
