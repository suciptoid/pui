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

  test "primitive dialog renders custom parts and hidden state" do
    assigns = %{show: false}

    html =
      rendered_to_string(~H"""
      <PUI.Dialog.Primitive.root
        id="confirm"
        show={@show}
        backdrop_id="scrim"
        content_id="panel"
      >
        Dialog body
      </PUI.Dialog.Primitive.root>
      <PUI.Dialog.Primitive.backdrop id="scrim" root_id="confirm" show={@show} />
      <PUI.Dialog.Primitive.content id="panel" show={@show} alert>
        Alert body
      </PUI.Dialog.Primitive.content>
      """)

    assert html =~ ~s(id="confirm")
    assert html =~ ~s(id="scrim" hidden)
    assert html =~ ~s(id="panel" hidden)
    assert html =~ ~s(role="alertdialog")
    assert html =~ ~s(phx-key="escape")
    assert html =~ "#scrim"
    assert html =~ "#panel"
    assert html =~ "Dialog body"
    assert html =~ "Alert body"
  end

  test "primitive dialog shows non-alert content and disables alert backdrop clicks" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Dialog.Primitive.backdrop id="alert-scrim" show alert />
      <PUI.Dialog.Primitive.content id="visible-panel" show>
        Visible body
      </PUI.Dialog.Primitive.content>
      """)

    assert html =~ ~s(id="alert-scrim")
    refute html =~ ~s(id="alert-scrim" hidden)
    assert html =~ ~s(id="visible-panel")
    refute html =~ ~s(id="visible-panel" hidden)
    assert html =~ ~s(role="dialog")
    refute html =~ ~s(id="alert-scrim" phx-click)
  end

  test "primitive dialog commands target default and custom part ids" do
    hide = PUI.Dialog.Primitive.hide("confirm", backdrop_id: "scrim", content_id: "panel")
    show = PUI.Dialog.Primitive.show("confirm", backdrop_id: "scrim", content_id: "panel")

    assert hide.ops == [
             ["set_attr", %{attr: ["hidden", true], to: "#scrim"}],
             ["set_attr", %{attr: ["hidden", true], to: "#panel"}],
             ["remove_class", %{names: ["overflow-hidden"], to: "body"}],
             ["pop_focus", %{}]
           ]

    assert show.ops == [
             ["push_focus", %{}],
             ["remove_attr", %{attr: "hidden", to: "#scrim"}],
             ["remove_attr", %{attr: "hidden", to: "#panel"}],
             ["add_class", %{names: ["overflow-hidden"], to: "body"}],
             ["focus_first", %{to: "#panel"}]
           ]
  end

  test "styled dialog renders sizes, title, trigger, footer, and alert mode" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dialog id="confirm-delete" size="lg" title="Delete item" alert show={true} show_close={false}>
        <:trigger :let={attrs}><button {attrs}>Delete</button></:trigger>
        Are you sure?
        <:footer :let={%{hide: hide}}><button phx-click={hide}>Cancel</button></:footer>
      </.dialog>
      <.dialog id="small-dialog" size="sm" show={false}>Small</.dialog>
      <.dialog id="extra-large-dialog" size="xl" show>Large</.dialog>
      <.dialog id="plain-dialog" size="" show>Plain</.dialog>
      """)

    assert html =~ "Delete item"
    assert html =~ "Are you sure?"
    assert html =~ "Cancel"
    assert html =~ ~s(role="alertdialog")
    assert html =~ "max-w-sm"
    assert html =~ "max-w-lg"
    assert html =~ "max-w-xl"
    assert html =~ "Small"
    assert html =~ "Large"
    assert html =~ "Plain"
  end
end
