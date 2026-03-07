defmodule Maui.ButtonTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import Maui.Button

  describe "button with variant='unstyled'" do
    test "renders with only custom class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button variant="unstyled" class="px-4 py-2 bg-blue-500">
          Custom Button
        </.button>
        """)

      assert html =~ "px-4 py-2 bg-blue-500"
      refute html =~ "bg-primary"
      refute html =~ "h-9"
    end

    test "renders without default variant classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button variant="unstyled">Unstyled</.button>
        """)

      refute html =~ "bg-primary"
      refute html =~ "bg-secondary"
      refute html =~ "rounded-md"
    end

    test "preserves button element type" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button variant="unstyled">Unstyled</.button>
        """)

      assert html =~ "<button"
    end
  end

  describe "styled button behavior" do
    test "class appends to styled variant" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button variant="secondary" class="w-full">
          Styled Button
        </.button>
        """)

      assert html =~ "bg-secondary"
      assert html =~ "w-full"
    end
  end
end
