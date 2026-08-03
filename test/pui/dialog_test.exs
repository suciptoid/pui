defmodule PUI.DialogTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Dialog

  test "renders the styled dialog" do
    assigns = %{}
    html = rendered_to_string(~H|<.dialog id="dialog">
  <p>Body</p>
</.dialog>|)
    assert html =~ "bg-background"
    assert html =~ ~s(role="dialog")
  end
end
