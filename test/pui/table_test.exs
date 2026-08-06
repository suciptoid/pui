defmodule PUI.TableTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Table

  test "renders the styled table" do
    assigns = %{rows: [%{id: 1, total: "$10"}]}
    html = rendered_to_string(~H|<.table id="invoices" rows={@rows}>
  <:col :let={row} label="Total">{row.total}</:col>
</.table>|)
    assert html =~ "bg-card"
  end

  test "renders captions, actions, row clicks, and custom row mapping" do
    assigns = %{
      rows: [%{id: 1, name: "Ada"}],
      row_id: fn row -> "person-#{row.id}" end,
      row_click: fn row -> "edit-#{row.id}" end,
      row_item: fn row -> %{row | name: String.upcase(row.name)} end
    }

    html =
      rendered_to_string(~H"""
      <.table
        id="people"
        rows={@rows}
        row_id={@row_id}
        row_click={@row_click}
        row_item={@row_item}
        action_label="Operations"
        class="outer"
        table_class="table"
        header_class="header"
        row_class="row"
        cell_class="cell"
        action_class="actions"
      >
        <:caption>People</:caption>
        <:col :let={person} label="Name" header_class="name-header" cell_class="name-cell">
          {person.name}
        </:col>
        <:action :let={person} class="action-slot">
          <button phx-value-id={person.id}>Edit</button>
        </:action>
      </.table>
      """)

    assert html =~ ~s(data-pui="table")
    assert html =~ ~s(id="people")
    assert html =~ "People"
    assert html =~ "ADA"
    assert html =~ ~s(id="person-1")
    assert html =~ ~s(phx-click="edit-1")
    assert html =~ "Operations"
    assert html =~ "action-slot"
    assert html =~ "name-header"
    assert html =~ "name-cell"
  end

  test "renders an empty row when an ordinary list has no rows" do
    assigns = %{rows: []}

    html =
      rendered_to_string(~H"""
      <.table id="empty-table" rows={@rows}>
        <:col :let={row} label="Name">{row}</:col>
        <:empty>No people found</:empty>
      </.table>
      """)

    assert html =~ ~s(id="empty-table")
    assert html =~ "No people found"
    assert html =~ ~s(colspan="1")
  end

  test "uses stream-style tuple ids for ordinary list rows" do
    assigns = %{rows: [{"person-1", %{name: "Ada"}}]}

    html =
      rendered_to_string(~H"""
      <.table id="stream-shaped" rows={@rows}>
        <:col :let={{_dom_id, person}} label="Name">{person.name}</:col>
      </.table>
      """)

    assert html =~ ~s(id="person-1")
    assert html =~ "Ada"
  end
end
