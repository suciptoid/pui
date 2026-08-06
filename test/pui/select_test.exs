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

  test "normalizes grouped and mixed option formats and selects the matching label" do
    html =
      render_component(&select/1,
        id: "food",
        value: "pear",
        options: [
          {"Fruit", ["Apple", {:banana, "Banana"}, %{value: "pear", label: "Pear"}]},
          %{value: "carrot"},
          %{label: "Dessert"},
          42,
          {"water", "Water"}
        ]
      )

    assert html =~ ~s(data-pui="group-label")
    assert html =~ "Fruit"
    assert html =~ ~s(data-value="Apple")
    assert html =~ ~s(data-value="banana")
    assert html =~ ~s(data-value="pear")
    assert html =~ "Pear"
    assert html =~ ~s(data-value="carrot")
    assert html =~ ~s(data-value="Dessert")
    assert html =~ ~s(data-value="42")
    assert html =~ ~s(data-value="water")
    assert html =~ ~s(data-placeholder="Pear")
  end

  test "renders searchable selects with header, footer, and no-results state" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.select id="searchable-food" searchable options={[]}>
        <:header>Recent foods</:header>
        <:footer><button type="button">Add food</button></:footer>
      </.select>
      """)

    assert html =~ ~s(data-pui="combobox-search")
    assert html =~ ~s(role="searchbox")
    assert html =~ ~s(data-pui="no-results")
    assert html =~ "Recent foods"
    assert html =~ "Add food"
  end

  test "maps a Phoenix form field into select identifiers, value, and errors" do
    form =
      Phoenix.Component.to_form(
        %{"category" => "books"},
        as: :post,
        action: :validate,
        errors: [category: {"is invalid", []}]
      )

    assigns = %{form: form}

    html =
      rendered_to_string(~H"""
      <.select field={@form[:category]} options={[{"books", "Books"}]} />
      """)

    assert html =~ ~s(id="post_category")
    assert html =~ ~s(name="post[category]")
    assert html =~ ~s(data-value="books")
    assert html =~ ~s(data-placeholder="Books")
    assert html =~ "is invalid"
  end

  test "renders a labeled select through the label wrapper" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.select id="timezone" label="Timezone" options={[{"utc", "UTC"}]} />
      """)

    assert html =~ "Timezone"
    assert html =~ ~s(for="timezone-input")
    assert html =~ ~s(phx-hook="PUI.Select")
  end
end
