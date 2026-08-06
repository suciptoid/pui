defmodule PUI.ButtonGroupTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.ButtonGroup

  test "renders vertical groups, separators, and text labels" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.button_group orientation="vertical" class="custom-group">
        <.button_group_text class="custom-label">Actions</.button_group_text>
        <.button_group_separator orientation="vertical" class="custom-separator" />
        <button type="button">Run</button>
      </.button_group>
      """)

    assert html =~ ~s(role="group")
    assert html =~ "flex-col"
    assert html =~ "custom-group"
    assert html =~ "custom-label"
    assert html =~ "Actions"
    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ "custom-separator"
    assert html =~ "Run"
  end
end
