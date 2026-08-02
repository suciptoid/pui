defmodule PUI.IconTest do
  use ExUnit.Case, async: false

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Icon, only: [icon: 1]

  setup do
    previous_provider = Application.get_env(:pui, :icon_provider)

    on_exit(fn ->
      if previous_provider do
        Application.put_env(:pui, :icon_provider, previous_provider)
      else
        Application.delete_env(:pui, :icon_provider)
      end
    end)

    :ok
  end

  test "renders semantic tokens with the default Heroicons provider" do
    assigns = %{}
    html = rendered_to_string(~H|<.icon name={:calendar} class="size-5 text-primary" />|)

    assert html =~ "hero-calendar"
    assert html =~ "size-5"
    assert html =~ ~s(aria-hidden="true")
  end

  test "passes classes, accessibility attributes, and rest attributes to a custom provider" do
    Application.put_env(:pui, :icon_provider, PUI.TestIconProvider)
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.icon name={:close} class="size-5 text-primary" data-testid="close-icon" />
      """)

    assert html =~ ~s(data-test-icon="close")
    assert html =~ ~s(class="size-5 text-primary")
    assert html =~ ~s(data-testid="close-icon")
    assert html =~ ~s(aria-hidden="true")
  end

  test "fails clearly when the configured provider does not implement render/2" do
    Application.put_env(:pui, :icon_provider, PUI)
    assigns = %{}

    assert_raise ArgumentError, ~r/PUI icon provider PUI must implement render\/2/, fn ->
      rendered_to_string(~H"<.icon name={:close} />")
    end
  end

  test "the default provider fails clearly for an unsupported token" do
    assigns = %{class: "size-4", rest: %{}}

    assert_raise ArgumentError, ~r/does not support semantic icon token/, fn ->
      PUI.Icon.Heroicons.render(:unsupported, assigns)
    end
  end
end
