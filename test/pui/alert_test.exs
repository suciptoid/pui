defmodule PUI.AlertTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import PUI.Alert

  describe "alert with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.alert variant="unstyled" class="my-alert">
          <:title>Title</:title>
          <:description>Description</:description>
        </.alert>
        """)

      assert html =~ "my-alert"
      refute html =~ "bg-card"
      refute html =~ "rounded-lg"
    end

    test "preserves title and description content" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.alert variant="unstyled">
          <:title>My Title</:title>
          <:description>My Description</:description>
        </.alert>
        """)

      assert html =~ "My Title"
      assert html =~ "My Description"
      refute html =~ "col-start-2"
    end
  end
end
