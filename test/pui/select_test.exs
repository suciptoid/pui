defmodule PUI.SelectTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Select

  test "renders the styled select" do
    assigns = %{}
    html = rendered_to_string(~H|<.select id="food">
  <.select_item value="a">Apple</.select_item>
</.select>|)
    assert html =~ "border-input"
    assert html =~ ~s(phx-hook="PUI.Select")
  end
end
