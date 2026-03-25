defmodule PUI.SelectTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Select

  describe "select with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="test" variant="unstyled" class="my-select">
          <.select_item value="a" class="my-item">Option A</.select_item>
        </.select>
        """)

      assert html =~ "my-select"
      assert html =~ "my-item"
      refute html =~ "border-input"
    end

    test "preserves ARIA attributes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="test" variant="unstyled">
          <.select_item value="a">Option A</.select_item>
        </.select>
        """)

      assert html =~ ~s(role="combobox")
      assert html =~ ~s(role="listbox")
      assert html =~ ~s(role="option")
      assert html =~ ~s(aria-haspopup="listbox")
      assert html =~ ~s(aria-expanded="false")
      assert html =~ ~s(aria-controls="test-listbox")
    end

    test "hides default icon in unstyled mode" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="test" variant="unstyled">
          <.select_item value="a">Option A</.select_item>
        </.select>
        """)

      refute html =~ "lucide lucide-chevron"
    end

    test "search input is linked to the listbox" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="test-search" searchable={true}>
          <.select_item value="a">Option A</.select_item>
        </.select>
        """)

      assert html =~ ~s(id="test-search-listbox")
      assert html =~ ~s(aria-controls="test-search-listbox")
    end
  end
end
