defmodule PUI.SeparatorTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Separator

  test "renders a decorative horizontal separator by default" do
    assigns = %{}
    html = rendered_to_string(~H|<.separator id="divider" />|)

    assert html =~ ~s(id="divider")
    assert html =~ ~s(data-orientation="horizontal")
    assert html =~ "h-px"
    refute html =~ ~s(role="separator")
  end

  test "renders semantic vertical separators" do
    assigns = %{}

    html =
      rendered_to_string(
        ~H|<.separator orientation="vertical" decorative={false} aria-label="Sections" />|
      )

    assert html =~ ~s(role="separator")
    assert html =~ ~s(aria-orientation="vertical")
    assert html =~ ~s(aria-label="Sections")
    assert html =~ "w-px"
  end
end
