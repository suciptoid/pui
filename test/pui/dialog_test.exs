defmodule PUI.DialogTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Dialog

  describe "dialog with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" variant="unstyled" class="my-dialog">
          <:trigger :let={attr}>
            <button {attr}>Open</button>
          </:trigger>
          <p>Content</p>
        </.dialog>
        """)

      assert html =~ "my-dialog"
      refute html =~ "bg-background"
      refute html =~ "fixed"
    end

    test "preserves ARIA attributes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" variant="unstyled">
          <:trigger :let={attr}>
            <button {attr}>Open</button>
          </:trigger>
          <p>Content</p>
        </.dialog>
        """)

      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
    end

    test "custom backdrop class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" variant="unstyled" class="backdrop-custom">
          <:trigger :let={attr}>
            <button {attr}>Open</button>
          </:trigger>
          <p>Content</p>
        </.dialog>
        """)

      assert html =~ "backdrop-custom"
    end
  end
end
