defmodule PUI.ProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Progress
  import PUI.TestComponentHelpers

  test "renders an accessible progressbar" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.progress value={42} label="Upload progress" value_text="42 percent" class="h-3" />
      """)

    assert html =~ ~s(role="progressbar")
    assert html =~ ~s(aria-label="Upload progress")
    assert html =~ ~s(aria-valuenow="42")
    assert html =~ ~s(aria-valuetext="42 percent")
    assert html =~ "h-3"
    assert html =~ "translateX(-58%)"
  end

  test "keeps the deprecated shared-module entry point rendering the same component" do
    html =
      render_deprecated_component(PUI.Components, :progress, %{
        min: 0,
        max: 10,
        value: 3,
        label: "Items",
        value_text: "3 of 10",
        class: "legacy-progress"
      })

    assert html =~ "legacy-progress"
    assert html =~ ~s(aria-valuemax="10")
  end
end
