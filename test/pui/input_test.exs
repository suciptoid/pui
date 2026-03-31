defmodule PUI.InputTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Input

  describe "input/1" do
    test "uses a flex column wrapper for labeled inputs" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.input id="email" label="Email" />
        """)

      assert html =~ ~s(class="flex w-full flex-col gap-3")
      refute html =~ ~s(class="grid w-full items-center gap-3")
    end

    test "renders aria-invalid as an explicit true value" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.input id="email" name="email" errors={["Required"]} />
        """)

      assert html =~ ~s(aria-invalid="true")
    end
  end
end
