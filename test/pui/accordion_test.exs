defmodule PUI.AccordionTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Accordion

  describe "accordion primitives" do
    test "render styled accordion markup" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion class="max-w-lg">
          <.accordion_item name="faq" open>
            <.accordion_trigger>Is it accessible?</.accordion_trigger>
            <.accordion_content>
              Yes. It uses native details and summary elements.
            </.accordion_content>
          </.accordion_item>
        </.accordion>
        """)

      assert html =~ ~s(class="w-full max-w-lg")
      assert html =~ ~s(<details name="faq" open)
      assert html =~ ~s(<summary)
      assert html =~ "group-open:rotate-180"
      assert html =~ "text-muted-foreground"
    end

    test "renders item without name for multi-open usage" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion>
          <.accordion_item>
            <.accordion_trigger>Question</.accordion_trigger>
            <.accordion_content>Answer</.accordion_content>
          </.accordion_item>
        </.accordion>
        """)

      refute html =~ ~s(name=")
      assert html =~ "<details"
    end

    test "unstyled primitives omit default classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion variant="unstyled" class="space-y-2">
          <.accordion_item variant="unstyled" class="rounded-xl border">
            <.accordion_trigger variant="unstyled" class="px-4 py-3" icon={false}>
              Plain Trigger
            </.accordion_trigger>
            <.accordion_content variant="unstyled" class="px-4 pb-4">
              Plain Content
            </.accordion_content>
          </.accordion_item>
        </.accordion>
        """)

      assert html =~ "space-y-2"
      assert html =~ "rounded-xl border"
      assert html =~ "px-4 py-3"
      assert html =~ "px-4 pb-4"
      refute html =~ "group border-b border-border"
      refute html =~ "hover:underline"
      refute html =~ "text-muted-foreground"
    end
  end
end
