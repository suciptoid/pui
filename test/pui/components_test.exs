defmodule PUI.ComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "renders field errors with a custom id and preserves empty output" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Components.field_error id="email-errors" errors={["Required", "Invalid"]} />
      <PUI.Components.field_error id="empty-errors" errors={[]} />
      """)

    assert html =~ ~s(id="email-errors-0")
    assert html =~ ~s(id="email-errors-1")
    assert html =~ ~s(aria-live="polite")
    assert html =~ "Required"
    assert html =~ "Invalid"
    refute html =~ "empty-errors-0"
  end

  test "translates supported error value types" do
    assert PUI.Components.translate_error({"%{field}", [field: :email]}) == "email"
    assert PUI.Components.translate_error({"%{count}", [count: 3]}) == "3"
    assert PUI.Components.translate_error({"%{ratio}", [ratio: 1.5]}) == "1.5"
    assert PUI.Components.translate_error({"%{value}", [value: ~c"abc"]}) == "abc"
    assert PUI.Components.translate_error({"%{value}", [value: [:a, :b]]}) == "[:a, :b]"
    assert PUI.Components.translate_error({"%{value}", [value: %{key: "value"}]}) =~ "key"
  end
end
