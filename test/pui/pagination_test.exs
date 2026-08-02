defmodule PUI.PaginationTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Pagination

  test "renders page links, ellipsis, and current-page semantics" do
    assigns = %{page_url: fn page -> "/items?page=#{page}" end}

    html =
      rendered_to_string(~H"""
      <.pagination
        id="items-pagination"
        current_page={3}
        total_pages={8}
        page_url={@page_url}
        link_mode="href"
      />
      """)

    assert html =~ ~s(id="items-pagination")
    assert html =~ ~s(href="/items?page=1")
    assert html =~ ~s(href="/items?page=3")
    assert html =~ ~s(aria-current="page")
    assert html =~ "not-prose"
    assert html =~ "list-none"
    assert html =~ "no-underline"
    assert html =~ "More pages"
    assert html =~ "Previous page"
    assert html =~ "Next page"
  end

  test "supports custom page slots and patch links" do
    assigns = %{page_url: fn page -> "/items?page=#{page}" end}

    html =
      rendered_to_string(~H"""
      <.pagination current_page={2} total_pages={3} page_url={@page_url} link_mode="patch">
        <:previous>Back</:previous>
        <:next>Forward</:next>
        <:page :let={page}>Page {page}</:page>
      </.pagination>
      """)

    assert html =~ ~s(data-phx-link="patch")
    assert html =~ "Back"
    assert html =~ "Forward"
    assert html =~ "Page 2"
    assert html =~ "min-w-9"
    assert html =~ "whitespace-nowrap"
  end

  test "disables previous and next links at the boundaries" do
    assigns = %{page_url: fn page -> "/items?page=#{page}" end}

    html =
      rendered_to_string(~H"""
      <.pagination current_page={1} total_pages={1} page_url={@page_url} link_mode="href" />
      """)

    assert html =~ ~s(aria-disabled="true")
    assert html =~ "pointer-events-none"
  end
end
