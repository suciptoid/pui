defmodule PUI.EmptyTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Empty

  test "renders its styled empty state" do
    assigns = %{}
    html = rendered_to_string(~H|<.empty>
  <:title>Nothing</:title>
</.empty>|)
    assert html =~ "border-dashed"
  end

  test "renders optional icon, description, actions, and custom content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.empty class="custom-empty" data-testid="empty-state">
        <:icon><span>Icon</span></:icon>
        <:title>No projects</:title>
        <:description>Create one to get started.</:description>
        <:actions><button type="button">Create project</button></:actions>
        Additional help
      </.empty>
      """)

    assert html =~ "custom-empty"
    assert html =~ ~s(data-testid="empty-state")
    assert html =~ ~s(data-slot="empty-icon")
    assert html =~ ~s(data-slot="empty-description")
    assert html =~ ~s(data-slot="empty-actions")
    assert html =~ "No projects"
    assert html =~ "Create one to get started."
    assert html =~ "Create project"
    assert html =~ "Additional help"
  end
end
