defmodule PUI.BreadcrumbTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Breadcrumb

  test "renders navigation, current page, and default semantic separator" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.breadcrumb id="project-breadcrumb">
        <.breadcrumb_list>
          <.breadcrumb_item>
            <.breadcrumb_link href="/projects">Projects</.breadcrumb_link>
          </.breadcrumb_item>
          <.breadcrumb_separator />
          <.breadcrumb_item>
            <.breadcrumb_page>Current</.breadcrumb_page>
          </.breadcrumb_item>
        </.breadcrumb_list>
      </.breadcrumb>
      """)

    assert html =~ ~s(aria-label="Breadcrumb")
    assert html =~ ~s(id="project-breadcrumb")
    assert html =~ ~s(href="/projects")
    assert html =~ ~s(aria-current="page")
    assert html =~ "not-prose"
    assert html =~ "list-none"
    assert html =~ "no-underline"
    assert html =~ "hero-chevron-right"
  end

  test "allows a custom separator and collapsed item" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.breadcrumb>
        <.breadcrumb_list>
          <.breadcrumb_ellipsis data-testid="ellipsis" />
          <.breadcrumb_separator>/</.breadcrumb_separator>
        </.breadcrumb_list>
      </.breadcrumb>
      """)

    assert html =~ ~s(data-testid="ellipsis")
    assert html =~ "More"
    assert html =~ "/"
    refute html =~ "hero-chevron-right"
  end
end
