defmodule PUI.BadgeTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Badge
  import PUI.TestComponentHelpers

  test "renders the canonical badge with its variants and custom class" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.badge variant="secondary" class="tracking-wide">Active</.badge>
      """)

    assert html =~ "bg-secondary"
    assert html =~ "tracking-wide"
    assert html =~ "Active"
  end

  test "keeps the deprecated shared-module entry point rendering the same component" do
    html =
      render_deprecated_component(PUI.Components, :badge, %{
        variant: "outline",
        class: "legacy-badge",
        inner_block: [%{inner_block: fn _, _ -> "Legacy" end}]
      })

    assert html =~ "legacy-badge"
    assert html =~ "text-foreground"
  end
end
