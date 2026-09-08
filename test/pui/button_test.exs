defmodule PUI.ButtonTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Button

  test "renders styled variants" do
    assigns = %{}
    html = rendered_to_string(~H|<.button variant="secondary" class="w-full">Save</.button>|)
    assert html =~ "bg-secondary"
    assert html =~ "w-full"
  end

  test "renders every supported variant and size" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.button variant="default">Default</.button>
      <.button variant="destructive">Destructive</.button>
      <.button variant="outline">Outline</.button>
      <.button variant="secondary">Secondary</.button>
      <.button variant="ghost">Ghost</.button>
      <.button variant="link">Link</.button>
      <.button size="sm">Small</.button>
      <.button size="lg">Large</.button>
      <.button size="icon" aria-label="Open">Icon</.button>
      """)

    assert html =~ "bg-foreground"
    assert html =~ "pui-button-emphasis"
    assert html =~ "bg-destructive"
    refute html =~ "--pui-button-color"
    assert html =~ "border border-border"
    assert html =~ "bg-secondary"
    assert html =~ "pui-button-subtle"
    assert html =~ "hover:bg-accent"
    assert html =~ "text-primary underline-offset-4"
    assert html =~ "h-8 rounded-md"
    assert html =~ "h-10 rounded-md"
    assert html =~ "size-9"
  end

  test "keeps tactile depth off flat and disabled buttons" do
    assigns = %{}

    disabled_html =
      rendered_to_string(~H"""
      <.button disabled>Disabled</.button>
      """)

    flat_html =
      rendered_to_string(~H"""
      <.button variant="ghost">Ghost</.button>
      <.button variant="link">Link</.button>
      """)

    assert disabled_html =~ "pui-button"
    assert disabled_html =~ ~s(disabled)
    assert flat_html =~ "hover:bg-accent"
    assert flat_html =~ "text-primary underline-offset-4"
    refute flat_html =~ "pui-button-emphasis"
    refute flat_html =~ "pui-button-subtle"
  end

  test "renders links through the button API" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.button href="/logout" data-testid="logout">Log out</.button>
      <.button navigate="/settings">Settings</.button>
      <.button patch="/profile">Profile</.button>
      """)

    assert html =~ ~s(href="/logout")
    assert html =~ ~s(href="/settings")
    assert html =~ ~s(href="/profile")
    refute html =~ ~s(data-testid="logout" type="button")
  end
end
