defmodule PUI.EmptyTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Empty

  test "renders its styled empty state" do
    assigns = %{}
    html = rendered_to_string(~H|<.empty>
  <:title>Nothing</:title>
</.empty>|)
    assert html =~ "border-dashed"
  end
end
