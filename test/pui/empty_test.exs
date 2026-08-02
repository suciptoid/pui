defmodule PUI.EmptyTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Empty

  test "renders all empty-state slots" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.empty id="empty-state">
        <:icon><span data-testid="empty-icon">!</span></:icon>
        <:title>No records</:title>
        <:description>Create a record to get started.</:description>
        <:actions><button type="button">Create</button></:actions>
        <span data-testid="extra">Extra</span>
      </.empty>
      """)

    assert html =~ ~s(data-slot="empty")
    assert html =~ ~s(data-testid="empty-icon")
    assert html =~ "No records"
    assert html =~ "Create a record"
    assert html =~ ~s(data-testid="extra")
    assert html =~ "border-dashed"
  end

  test "unstyled variant keeps structure without default presentation" do
    assigns = %{}
    html = rendered_to_string(~H|<.empty variant="unstyled">
  <:title>Nothing</:title>
</.empty>|)

    assert html =~ ~s(data-slot="empty-title")
    assert html =~ "Nothing"
    refute html =~ "border-dashed"
  end
end
