defmodule PUI.DialogTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Dialog

  describe "default dialog" do
    test "renders title and close button with aligned header layout" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" title="Dialog Title">
          <p>Content</p>
        </.dialog>
        """)

      assert html =~ "Dialog Title"
      assert html =~ ~s(aria-label="Close dialog")
      assert html =~ "hero-x-mark"
      assert html =~ ~s(class="flex items-center gap-4")
      assert html =~ ~s(class="flex-1 text-lg font-semibold leading-none tracking-tight")
      assert html =~ ~s(class="hero-x-mark size-5")
      refute html =~ "<h2"
    end

    test "can hide the close button" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" title="Dialog Title" show_close={false}>
          <p>Content</p>
        </.dialog>
        """)

      assert html =~ "Dialog Title"
      refute html =~ ~s(aria-label="Close dialog")
    end

    test "uses a scrollable body and fixed footer" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" title="Dialog Title">
          <p>Content</p>
          <:footer>
            <button type="button">Save</button>
          </:footer>
        </.dialog>
        """)

      assert html =~ "max-h-[calc(100vh-2rem)]"
      assert html =~ "overflow-hidden"
      assert html =~ ~s(class="min-h-0 flex-1 overflow-y-auto")
      assert html =~ ~s(class="shrink-0")
      assert html =~ "Save"
    end
  end

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

    test "does not render the default close button" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dialog id="test" variant="unstyled">
          <p>Content</p>
        </.dialog>
        """)

      refute html =~ ~s(aria-label="Close dialog")
    end
  end
end
