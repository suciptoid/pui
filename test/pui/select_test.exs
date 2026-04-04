defmodule PUI.SelectTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest
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
      assert html =~ ~s(id="test-trigger")
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

    test "label points to the trigger button" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="food" label="Select Food">
          <.select_item value="a">Option A</.select_item>
        </.select>
        """)

      assert html =~ ~s(Select Food\n</label>)
    end

    test "label falls back to the field name when the field id is blank" do
      form = Phoenix.Component.to_form(%{"category" => ""}, as: :user)
      field = %{form[:category] | id: nil}
      assigns = %{field: field}

      html =
        rendered_to_string(~H"""
        <.select field={@field} label="Category" options={["Option A"]} />
        """)

      assert html =~ ~s(id="user[category]-trigger")
    end

    test "renders aria-invalid as an explicit true value when errors exist" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.select id="food" name="food" errors={["Required"]}>
          <.select_item value="a">Option A</.select_item>
        </.select>
        """)

      assert html =~ ~s(aria-invalid="true")
    end
  end
end
