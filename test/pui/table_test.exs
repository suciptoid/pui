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
end
