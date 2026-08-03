defmodule PUI.ButtonTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Button

  test "renders styled variants" do
    assigns = %{}
    html = rendered_to_string(~H|<.button variant="secondary" class="w-full">Save</.button>|)
    assert html =~ "bg-secondary"
    assert html =~ "w-full"
  end
end
