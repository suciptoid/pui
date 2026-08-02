defmodule PUI.CardTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.Card

  test "renders the canonical Card family" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.card id="profile-card" data-kind="profile">
        <.card_header>
          <.card_title>Profile</.card_title>
          <.card_description>Account details</.card_description>
          <.card_action>Edit</.card_action>
        </.card_header>
        <.card_content>Content</.card_content>
        <.card_footer class="justify-end">Save</.card_footer>
      </.card>
      """)

    assert html =~ ~s(id="profile-card")
    assert html =~ ~s(data-kind="profile")
    assert html =~ "Profile"
    assert html =~ "Account details"
    assert html =~ "col-start-2"
    assert html =~ "justify-end"
    assert html =~ "Content"
    assert html =~ "Save"
  end

  test "keeps the deprecated Container Card entry point rendering" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Container.card class="legacy-card">Legacy</PUI.Container.card>
      """)

    assert html =~ "legacy-card"
    assert html =~ "bg-card"
  end
end
