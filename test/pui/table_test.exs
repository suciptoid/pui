defmodule PUI.TableTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Table

  alias Phoenix.LiveView.JS

  test "renders styled columns and rows" do
    assigns = %{rows: [%{id: "one", name: "One"}, %{id: "two", name: "Two"}]}

    html =
      rendered_to_string(~H"""
      <.table id="items" rows={@rows}>
        <:col :let={item} label="Name">{item.name}</:col>
      </.table>
      """)

    assert html =~ ~s(data-pui="table")
    assert html =~ ~s(id="items")
    assert html =~ "bg-card"
    assert html =~ "Name"
    assert html =~ "One"
    assert html =~ ~s(id="one")
    assert html =~ ~s(id="two")
  end

  test "renders action slots and row clicks" do
    assigns = %{rows: [%{id: 7, name: "Seven"}]}

    html =
      rendered_to_string(~H"""
      <.table id="items" rows={@rows} row_click={fn row -> JS.push("show", value: %{id: row.id}) end}>
        <:col :let={item} label="Name">{item.name}</:col>
        <:action :let={item} class="row-actions">
          <button phx-click="edit" phx-value-id={item.id}>Edit</button>
        </:action>
      </.table>
      """)

    assert html =~ ~s(phx-click="[[&quot;push&quot;)
    assert html =~ ~s(&quot;event&quot;:&quot;show&quot;)
    assert html =~ ~s(phx-click="edit")
    assert html =~ ~s(phx-value-id="7")
    assert html =~ "row-actions"
    assert html =~ ~s(<span class="sr-only">Actions</span>)
  end

  test "supports part classes and unstyled mode" do
    assigns = %{rows: [%{id: "invoice-1", total: "$10"}]}

    html =
      rendered_to_string(~H"""
      <.table
        id="invoices"
        rows={@rows}
        variant="unstyled"
        class="custom-wrapper"
        table_class="custom-table"
        header_class="custom-header"
        row_class="custom-row"
        cell_class="custom-cell"
      >
        <:col :let={invoice} label="Total">{invoice.total}</:col>
      </.table>
      """)

    assert html =~ "custom-wrapper"
    assert html =~ "custom-table"
    assert html =~ "custom-header"
    assert html =~ "custom-row"
    assert html =~ "custom-cell"
    refute html =~ "bg-card"
    refute html =~ "hover:bg-muted/30"
  end

  test "renders an empty slot for an ordinary empty list" do
    assigns = %{rows: []}

    html =
      rendered_to_string(~H"""
      <.table id="items" rows={@rows}>
        <:col label="Name">Name</:col>
        <:empty>
          <p>No items found.</p>
        </:empty>
      </.table>
      """)

    assert html =~ "No items found."
    assert html =~ ~s(colspan="1")
  end

  test "renders LiveStream metadata and stream row tuples" do
    stream =
      Phoenix.LiveView.LiveStream.new(
        :items,
        1,
        [%{id: 1, name: "One"}],
        []
      )
      |> Phoenix.LiveView.LiveStream.mark_consumable()

    assigns = %{rows: stream}

    html =
      rendered_to_string(~H"""
      <.table id="items" rows={@rows}>
        <:col :let={{_dom_id, item}} label="Name">{item.name}</:col>
      </.table>
      """)

    assert html =~ ~s(phx-update="stream")
    assert html =~ "One"
  end
end
