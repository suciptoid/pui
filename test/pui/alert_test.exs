defmodule PUI.AlertTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Alert

  test "renders the styled alert" do
    assigns = %{}
    html = rendered_to_string(~H|<.alert variant="destructive">Problem</.alert>|)
    assert html =~ "text-destructive"
  end

  test "renders default alert slots with semantic status metadata" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.alert data-testid="notice">
        <:icon><span>!</span></:icon>
        <:title class="custom-title">Saved</:title>
        <:description class="custom-description">Your changes are live.</:description>
      </.alert>
      """)

    assert html =~ ~s(role="status")
    assert html =~ ~s(aria-live="polite")
    assert html =~ ~s(data-testid="notice")
    assert html =~ ~s(data-icon="alert-icon")
    assert html =~ "Saved"
    assert html =~ "Your changes are live."
  end

  test "honors a caller-provided alert role" do
    assigns = %{}
    html = rendered_to_string(~H|<.alert role="log">Activity</.alert>|)

    assert html =~ ~s(role="log")
    assert html =~ ~s(aria-live="polite")
  end
end
