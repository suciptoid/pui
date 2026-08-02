defmodule PUI.AvatarTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Avatar

  test "renders image and accessible alt text when src is present" do
    assigns = %{}
    html = rendered_to_string(~H|<.avatar src="/avatar.png" alt="Ada" size="lg" />|)

    assert html =~ ~s(src="/avatar.png")
    assert html =~ ~s(alt="Ada")
    assert html =~ "size-12"
    refute html =~ ~s(data-slot="avatar-fallback")
  end

  test "renders text and slot fallbacks without an image" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <div>
        <.avatar fallback_text="SC" data-testid="text-avatar" />
        <.avatar data-testid="slot-avatar">
          <:fallback>TM</:fallback>
        </.avatar>
      </div>
      """)

    assert html =~ "SC"
    assert html =~ "TM"
    assert html =~ ~s(data-testid="text-avatar")
    assert html =~ ~s(data-testid="slot-avatar")
  end
end
