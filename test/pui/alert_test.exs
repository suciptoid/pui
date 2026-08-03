defmodule PUI.AlertTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Alert

  test "renders the styled alert" do
    assigns = %{}
    html = rendered_to_string(~H|<.alert variant="destructive">Problem</.alert>|)
    assert html =~ "text-destructive"
  end
end
