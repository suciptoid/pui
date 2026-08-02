defmodule PUI.SkeletonTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Skeleton

  test "renders an aria-hidden loading placeholder" do
    assigns = %{}
    html = rendered_to_string(~H|<.skeleton id="loading-row" class="h-6 w-32" />|)

    assert html =~ ~s(data-slot="skeleton")
    assert html =~ ~s(aria-hidden="true")
    assert html =~ ~s(id="loading-row")
    assert html =~ "animate-pulse"
    assert html =~ "h-6 w-32"
  end
end
