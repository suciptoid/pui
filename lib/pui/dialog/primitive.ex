defmodule PUI.Dialog.Primitive do
  @moduledoc """
  Zero-style dialog parts.

  The parts provide dialog semantics and LiveView focus commands without any
  presentation classes. Compose them when an application owns dialog markup.

  `hide/2` and `show/2` target the backdrop and content elements by ID. They
  default to the `<root-id>-backdrop` and `<root-id>-content` convention; pass
  `:backdrop_id` and `:content_id` when the application uses other IDs.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :show, :boolean, default: false
  attr :backdrop_id, :string, default: nil, doc: "Defaults to `<id>-backdrop`."
  attr :content_id, :string, default: nil, doc: "Defaults to `<id>-content`."
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns) do
    cancel_action =
      if assigns.show do
        assigns.on_cancel
      else
        JS.exec(assigns.on_cancel, "phx-remove", to: "##{assigns.id}")
      end

    opts =
      Enum.reject(
        [backdrop_id: assigns.backdrop_id, content_id: assigns.content_id],
        fn {_k, v} -> is_nil(v) end
      )

    assigns =
      assigns
      |> assign(:cancel_action, cancel_action)
      |> assign(:hide_action, hide(assigns.id, opts))
      |> assign(:show_action, show(assigns.id, opts))

    ~H"""
    <div
      id={@id}
      phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
      phx-key="escape"
      phx-remove={@hide_action}
      data-cancel={@cancel_action}
      {@rest}
    >
      {render_slot(@inner_block, %{
        hide: JS.exec("data-cancel", to: "##{@id}"),
        show: @show_action
      })}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :alert, :boolean, default: false

  attr :root_id, :string,
    default: nil,
    doc:
      "ID of the dialog root to cancel on backdrop click. Defaults to `id` without `-backdrop`."

  attr :rest, :global

  def backdrop(assigns) do
    root_id = assigns.root_id || String.replace_suffix(assigns.id, "-backdrop", "")
    assigns = assign(assigns, :root_id, root_id)

    ~H"""
    <div
      id={@id}
      hidden={not @show}
      phx-click={if @alert, do: nil, else: JS.exec("data-cancel", to: "##{@root_id}")}
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

  def hide(id, opts \\ []) do
    {backdrop_id, content_id} = part_ids(id, opts)

    JS.set_attribute({"hidden", true}, to: "##{backdrop_id}")
    |> JS.set_attribute({"hidden", true}, to: "##{content_id}")
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def show(id, opts \\ []) do
    {backdrop_id, content_id} = part_ids(id, opts)

    JS.push_focus()
    |> JS.remove_attribute("hidden", to: "##{backdrop_id}")
    |> JS.remove_attribute("hidden", to: "##{content_id}")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{content_id}")
  end

  defp part_ids(id, opts) do
    {Keyword.get(opts, :backdrop_id, "#{id}-backdrop"),
     Keyword.get(opts, :content_id, "#{id}-content")}
  end
end
