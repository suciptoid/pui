defmodule PUI.Dialog.Primitive do
  @moduledoc """
  Zero-style dialog parts.

  The parts provide dialog semantics and LiveView focus commands without any
  presentation classes. Compose them when an application owns dialog markup.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :show, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns) do
    cancel_action =
      if assigns.show do
        assigns.on_cancel
      else
        JS.exec(assigns.on_cancel, "phx-remove", to: "##{assigns.id}")
      end

    assigns = assign(assigns, :cancel_action, cancel_action)

    ~H"""
    <div
      id={@id}
      phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
      phx-key="escape"
      phx-remove={hide(@id)}
      data-cancel={@cancel_action}
      {@rest}
    >
      {render_slot(@inner_block, %{hide: JS.exec("data-cancel", to: "##{@id}"), show: show(@id)})}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :alert, :boolean, default: false
  attr :rest, :global

  def backdrop(assigns) do
    ~H"""
    <div
      id={@id}
      hidden={not @show}
      phx-click={
        if @alert,
          do: nil,
          else: JS.exec("data-cancel", to: "##{@id |> String.replace_suffix("-backdrop", "")}")
      }
      {@rest}
    />
    """
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :alert, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def content(assigns) do
    ~H"""
    <div
      id={@id}
      hidden={not @show}
      role={if @alert, do: "alertdialog", else: "dialog"}
      aria-modal="true"
      tabindex="-1"
      {@rest}
    >
      <.focus_wrap id={"#{@id}-focus"}>{render_slot(@inner_block)}</.focus_wrap>
    </div>
    """
  end

  def hide(id) do
    JS.set_attribute({"hidden", true}, to: "##{id}-backdrop")
    |> JS.set_attribute({"hidden", true}, to: "##{id}-content")
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def show(id) do
    JS.push_focus()
    |> JS.remove_attribute("hidden", to: "##{id}-backdrop")
    |> JS.remove_attribute("hidden", to: "##{id}-content")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end
end
