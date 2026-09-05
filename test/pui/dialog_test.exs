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

  test "server-controlled dialog binds phx-window-keydown only when open, and excludes phx-remove" do
    assigns = %{
      on_cancel: Phoenix.LiveView.JS.push("close")
    }

    # Open server-controlled dialog
    open_html =
      rendered_to_string(~H"""
      <.dialog id="open-dialog" show={true} on_cancel={@on_cancel}>
        <p>Open content</p>
      </.dialog>
      """)

    # Root div has window keydown when open
    assert open_html =~ ~s(id="open-dialog")
    assert open_html =~ ~s(phx-window-keydown=)
    assert open_html =~ ~s(phx-key="escape")
    # Server-controlled dialog must NOT run phx-remove (hide_dialog/1)
    refute open_html =~ ~s(id="open-dialog" phx-remove)

    refute open_html =~
             ~s(data-cancel="[[&quot;exec&quot;,{&quot;attr&quot;:&quot;phx-remove&quot;)

    # Content div does NOT attach phx-keydown when server-controlled
    refute open_html =~ ~s(id="open-dialog-content" phx-keydown=)
    refute open_html =~ ~s(id="open-dialog-content" hidden)
    refute open_html =~ ~s(id="open-dialog-backdrop" hidden)

    # Closed server-controlled dialog
    closed_html =
      rendered_to_string(~H"""
      <.dialog id="closed-dialog" show={false} on_cancel={@on_cancel}>
        <p>Closed content</p>
      </.dialog>
      """)

    # Root div must NOT bind window keydown when closed
    refute closed_html =~ ~s(id="closed-dialog" phx-window-keydown=)
    refute closed_html =~ ~s(id="closed-dialog" phx-key=)
    # Server-controlled dialog must NOT run phx-remove
    refute closed_html =~ ~s(id="closed-dialog" phx-remove)

    refute closed_html =~
             ~s(data-cancel="[[&quot;exec&quot;,{&quot;attr&quot;:&quot;phx-remove&quot;)

    # Content div does not have phx-keydown
    refute closed_html =~ ~s(id="closed-dialog-content" phx-keydown=)
    # Both content and backdrop are hidden
    assert closed_html =~ ~s(id="closed-dialog-content")
    assert closed_html =~ ~s(id="closed-dialog-backdrop")
    assert closed_html =~ ~s(hidden)
    refute closed_html =~ ~s(phx-window-keydown)
  end

  test "client-controlled dialog handles escape via content keydown, not window keydown" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dialog id="client-dialog" title="Client Dialog">
        <:trigger :let={attr}><button {attr}>Open</button></:trigger>
        <p>Client content</p>
      </.dialog>
      """)

    # Root div must NOT bind global window keydown
    refute html =~ ~s(id="client-dialog" phx-window-keydown=)
    refute html =~ ~s(id="client-dialog" phx-key=)
    # Root div has phx-remove for client hide_dialog
    assert html =~ ~s(id="client-dialog" phx-remove=)
    # data-cancel executes phx-remove
    assert html =~ ~s(data-cancel=)
    assert html =~ ~s(attr&quot;:&quot;phx-remove&quot;)
    # Content div captures escape key within focused content
    assert html =~ ~s(id="client-dialog-content")
    assert html =~ ~s(phx-keydown=)
    assert html =~ ~s(phx-key="escape")
    assert html =~ ~s(id="client-dialog-backdrop")
  end

  test "custom content slot receives keydown attributes only for client-controlled dialogs" do
    assigns = %{}

    client_html =
      rendered_to_string(~H"""
      <.dialog id="custom-client">
        <:content :let={{attrs, %{hide: hide}}}>
          <div {attrs}>
            <button phx-click={hide}>Close</button>
          </div>
        </:content>
      </.dialog>
      """)

    assert client_html =~ ~s(id="custom-client-content")
    assert client_html =~ ~s(phx-keydown=)
    assert client_html =~ ~s(phx-key="escape")

    server_html =
      rendered_to_string(~H"""
      <.dialog id="custom-server" show={true}>
        <:content :let={{attrs, %{hide: hide}}}>
          <div {attrs}>
            <button phx-click={hide}>Close</button>
          </div>
        </:content>
      </.dialog>
      """)

    assert server_html =~ ~s(id="custom-server-content")
    refute server_html =~ ~s(id="custom-server-content" phx-keydown=)
    refute server_html =~ ~s(id="custom-server-content" phx-key=)
  end

  test "multiple dialogs: inactive dialog does not bind window keydown and cancel_action excludes phx-remove" do
    assigns = %{
      open_a: true,
      open_b: false,
      on_cancel_a: Phoenix.LiveView.JS.push("close_a"),
      on_cancel_b: Phoenix.LiveView.JS.push("close_b")
    }

    html =
      rendered_to_string(~H"""
      <.dialog id="dialog-a" show={@open_a} on_cancel={@on_cancel_a}>
        <p>Dialog A</p>
      </.dialog>
      <.dialog id="dialog-b" show={@open_b} on_cancel={@on_cancel_b}>
        <p>Dialog B</p>
      </.dialog>
      """)

    # Dialog A is open: binds window keydown, but does NOT have phx-remove
    assert html =~ ~s(id="dialog-a")
    assert html =~ ~s(phx-window-keydown=)
    refute html =~ ~s(id="dialog-a" phx-remove=)

    # Dialog B is inactive: does NOT bind window keydown, does NOT have phx-remove
    refute html =~ ~s(id="dialog-b" phx-window-keydown=)
    refute html =~ ~s(id="dialog-b" phx-remove=)
    refute html =~ ~s(id="dialog-b-content" phx-keydown=)
  end
end
