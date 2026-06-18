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

      assert html =~ ~s(flex w-full flex-col gap-3 pb-3)
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

    test "translates error tuples with charlist placeholders and values" do
      assert PUI.Components.translate_error(
               {~c"%{count} items for %{field}", [count: ~c"12", field: ~c"name"]}
             ) ==
               "12 items for name"
    end
  end

  describe "checkbox/1" do
    test "renders a hidden unchecked input alongside the visible checkbox" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.checkbox id="terms" name="terms" />
        """)

      assert html =~
               ~s(<input type="hidden" name="terms" value="false")

      assert html =~ ~s(<input id="terms")
      assert html =~ ~s(type="checkbox")
    end

    test "uses value=true and omits the checked attribute when field value is false" do
      assigns = %{form: Phoenix.Component.to_form(%{"is_default" => false}, as: :address)}

      html =
        rendered_to_string(~H"""
        <.checkbox field={@form[:is_default]} />
        """)

      assert html =~ ~s(type="hidden" name="address[is_default]" value="false")
      assert html =~ ~s(value="true")
      refute html =~ ~r/\schecked(=|>|\z)/
    end

    test "uses value=true and adds the checked attribute when field value is true" do
      assigns = %{form: Phoenix.Component.to_form(%{"is_default" => true}, as: :address)}

      html =
        rendered_to_string(~H"""
        <.checkbox field={@form[:is_default]} />
        """)

      assert html =~ ~s(type="hidden" name="address[is_default]" value="false")
      assert html =~ ~s(value="true")
      assert html =~ ~r/\schecked(=|>|\z)/
    end

    test "honors an explicit rest checked attribute when no field is provided" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.checkbox id="newsletter" name="newsletter" checked />
        """)

      assert html =~ ~r/\schecked(=|>|\z)/
      assert html =~ ~s(type="hidden" name="newsletter" value="false")
    end

    test "renders the hidden input inside the labeled wrapper" do
      assigns = %{form: Phoenix.Component.to_form(%{"is_default" => true}, as: :address)}

      html =
        rendered_to_string(~H"""
        <.checkbox field={@form[:is_default]} label="Use as default" />
        """)

      assert html =~ ~s(type="hidden" name="address[is_default]" value="false")
      assert html =~ ~s(<input id=)
      assert html =~ ~s(value="true")
      assert html =~ ~r/\schecked(=|>|\z)/
      assert html =~ ~s(Use as default)
    end
  end
end
