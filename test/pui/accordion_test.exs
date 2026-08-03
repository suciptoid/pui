defmodule PUI.AccordionTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Accordion

  test "renders a styled native accordion" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.accordion>
        <.accordion_item>
          <.accordion_trigger>Question</.accordion_trigger><.accordion_content>
            Answer
          </.accordion_content>
        </.accordion_item>
      </.accordion>
      """)

    assert html =~ "<details"
    assert html =~ "text-muted-foreground"
  end
end
