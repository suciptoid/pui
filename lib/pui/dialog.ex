defmodule PUI.Dialog do
  @moduledoc """
  A modal dialog component for LiveView applications.

  ## Basic Usage

  The simplest way to use a dialog is with a trigger button:

      <.dialog id="my-dialog" title="Dialog title">
        <:trigger :let={attr}>
          <.button {attr}>Open Dialog</.button>
        </:trigger>
        <p>Dialog content goes here.</p>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button>Confirm</.button>
          </div>
        </:footer>
      </.dialog>

  ## Accessing Hide/Show Actions

  Use `:let` to access the `hide` and `show` JS commands:

      <.dialog :let={%{hide: hide, show: show}} id="my-dialog" title="Project details">
        <:trigger :let={attr}>
          <.button {attr}>Open</.button>
        </:trigger>
        <p>Content</p>
        <:footer>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Close</.button>
            <.button phx-click={show}>Refresh focus</.button>
          </div>
        </:footer>
      </.dialog>

  ## Server-Controlled Dialog

  Control dialog visibility from your LiveView using the `show` attribute:

      # In your LiveView
      def mount(_params, _session, socket) do
        {:ok, assign(socket, show_dialog: false)}
      end

      def handle_event("open", _, socket), do: {:noreply, assign(socket, show_dialog: true)}
      def handle_event("close", _, socket), do: {:noreply, assign(socket, show_dialog: false)}

      # In template - use on_cancel to sync state when dismissed via backdrop/escape
      <.button phx-click="open">Open</.button>
      <.dialog id="my-dialog" show={@show_dialog} on_cancel={JS.push("close")}>
        <p>Server-controlled content</p>
        <.button phx-click="close">Close</.button>
      </.dialog>

  ### show={} vs :if={}

  Two approaches for server-controlled dialogs:

  | Approach | Behavior |
  |----------|----------|
  | `show={@visible}` | Dialog stays in DOM, visibility toggled. Form state preserved, animations work. |
  | `:if={@visible}` | Dialog mounted/unmounted. Form state resets, no exit animations. |

  **Using `show={}`** (recommended for most cases):

      <.dialog id="dialog" show={@show_dialog} on_cancel={JS.push("close")}>
        ...
      </.dialog>

  **Using `:if={}`** (when you want fresh state each time):

      <.dialog :if={@show_dialog} id="dialog" show={true} on_cancel={JS.push("close")}>
        ...
      </.dialog>

  ## Alert Dialog

  Use `alert={true}` to prevent closing via backdrop click (escape still works):

      <.dialog id="confirm-delete" title="Delete item" alert={true}>
        <:trigger :let={attr}>
          <.button variant="destructive" {attr}>Delete</.button>
        </:trigger>
        <p>Are you sure? This cannot be undone.</p>
      </.dialog>

  ## Dialog Title

  Use the `title` attribute to render a built-in dialog heading:

      <.dialog id="profile-dialog" title="Edit profile">
        <:trigger :let={attr}>
          <.button {attr}>Edit profile</.button>
        </:trigger>
        <p>Update your profile details.</p>
      </.dialog>

  The close button is shown by default. Disable it with `show_close={false}`:

      <.dialog id="checkout-dialog" title="Checkout" show_close={false}>
        <p>Review your order before continuing.</p>
      </.dialog>

  ## Scrollable Body with Footer

  The default dialog keeps the title and footer fixed while the body scrolls automatically:

      <.dialog id="activity-dialog" title="Recent activity" size="lg">
        <div class="space-y-4">
          <p :for={_ <- 1..12}>Scrollable content</p>
        </div>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Close</.button>
            <.button>Save changes</.button>
          </div>
        </:footer>
      </.dialog>

  ## Dialog Sizes

  Control max-width with the `size` attribute:

      <.dialog id="small" size="sm">...</.dialog>   # sm:max-w-sm
      <.dialog id="medium" size="md">...</.dialog>  # md:max-w-md (default)
      <.dialog id="large" size="lg">...</.dialog>   # lg:max-w-lg
      <.dialog id="xlarge" size="xl">...</.dialog>  # xl:max-w-xl

  ## Custom Content Slot

  Override the default content container for full customization. This bypasses the built-in
  title, scrollable body, and footer layout:

      <.dialog id="custom">
        <:trigger :let={attr}>
          <.button {attr}>Open</.button>
        </:trigger>
        <:content :let={{attrs, %{hide: hide}}}>
          <div class="my-custom-dialog-class" {attrs}>
            <p>Fully customized container</p>
            <.button phx-click={hide}>Close</.button>
          </div>
        </:content>
      </.dialog>

  ## Programmatic Show/Hide

  Use `show_dialog/1` and `hide_dialog/1` functions directly:

      <.button phx-click={PUI.Dialog.show_dialog("my-dialog")}>Open</.button>
      <.button phx-click={PUI.Dialog.hide_dialog("my-dialog")}>Close</.button>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | required | Unique identifier for the dialog |
  | `show` | `boolean` | `false` | Control visibility from server |
  | `alert` | `boolean` | `false` | Prevent backdrop click dismiss |
  | `size` | `string` | `"md"` | Max width: "sm", "md", "lg", "xl" |
  | `title` | `string` | `nil` | Optional built-in title for the default dialog header |
  | `show_close` | `boolean` | `true` | Show the built-in close button on default dialogs |
  | `on_cancel` | `JS` | `%JS{}` | JS command to run on cancel |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `inner_block` | Main dialog body content (scrolls when needed in the default layout) |
  | `footer` | Optional fixed footer for actions in the default layout |
  | `trigger` | Button/element to open dialog (receives `phx-click` attr) |
  | `content` | Override content container (receives attrs and hide/show) |
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :class, :string, default: ""
  attr :rest, :global
  attr :is_unstyled, :boolean, default: false
  slot :inner_block

  def backdrop(%{is_unstyled: is_unstyled} = assigns) do
    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 fixed inset-0 z-50 bg-black/50",
            @class
          ]
        end
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :rest, :global
  attr :is_unstyled, :boolean, default: false
  attr :title, :string, default: nil
  attr :show_close, :boolean, default: true
  attr :hide, JS, default: %JS{}
  slot :inner_block
  slot :footer

  def content(%{is_unstyled: is_unstyled} = assigns) do
    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div
      id={@id}
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95",
            "bg-background fixed top-[50%] left-[50%] z-50 flex w-full max-w-[calc(100%-2rem)] max-h-[calc(100vh-2rem)] translate-x-[-50%] translate-y-[-50%] flex-col overflow-hidden rounded-lg border px-6 py-3 shadow-lg duration-200 sm:max-w-lg",
            @class
          ]
        end
      }
      {@rest}
    >
      <.focus_wrap
        id={"#{@id}-focus"}
        class={if @is_unstyled, do: nil, else: "flex min-h-0 flex-1 flex-col gap-4"}
      >
        <%= if @is_unstyled do %>
          {render_slot(@inner_block)}
          {render_slot(@footer)}
        <% else %>
          <div :if={@show_close or @title} class="flex items-center gap-4">
            <div class="flex-1 text-lg font-semibold leading-none tracking-tight">{@title || ""}</div>
            <button
              :if={@show_close}
              type="button"
              class="ring-offset-background focus-visible:ring-ring inline-flex shrink-0 items-center justify-center rounded opacity-70 transition-opacity hover:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2"
              phx-click={@hide}
              aria-label="Close dialog"
            >
              <span class="hero-x-mark size-5" />
            </button>
          </div>
          <div class="min-h-0 flex-1 overflow-y-auto">
            {render_slot(@inner_block)}
          </div>
          <div :if={@footer != []} class="shrink-0">
            {render_slot(@footer)}
          </div>
        <% end %>
      </.focus_wrap>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :alert, :boolean, default: false
  attr :show, :boolean, default: false, doc: "Control dialog visibility from server"
  attr :size, :string, values: ["sm", "md", "lg", "xl"], default: "md"
  attr :title, :string, default: nil
  attr :show_close, :boolean, default: true
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(aria-label aria-labelledby aria-describedby)

  slot :inner_block
  slot :footer, required: false, doc: "Optional fixed footer for the default dialog layout"
  slot :trigger, required: false
  slot :content, required: false, doc: "To override the content container"

  def dialog(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    size_class =
      if is_unstyled do
        ""
      else
        case assigns[:size] do
          "sm" -> "sm:max-w-sm"
          "md" -> "md:max-w-md"
          "lg" -> "lg:max-w-lg"
          "xl" -> "xl:max-w-xl"
        end
      end

    cancel_action =
      if assigns[:show] do
        assigns[:on_cancel]
      else
        JS.exec(assigns[:on_cancel], "phx-remove")
      end

    assigns =
      assigns
      |> assign(:size_class, size_class)
      |> assign(:cancel_action, cancel_action)
      |> assign(:is_unstyled, is_unstyled)

    ~H"""
    <div
      id={@id}
      phx-window-keydown={JS.exec("data-cancel")}
      phx-key="escape"
      phx-remove={hide_dialog(@id)}
      data-cancel={@cancel_action}
    >
      {render_slot(@trigger, %{
        "phx-click": show_dialog(@id)
      })}
      <.backdrop
        id={"#{@id}-backdrop"}
        hidden={not @show}
        class={@class}
        is_unstyled={@is_unstyled}
        phx-click={if @alert, do: nil, else: JS.exec("data-cancel", to: "##{@id}")}
      />

      <%= if @content != [] do %>
        {render_slot(
          @content,
          {%{id: "#{@id}-content", hidden: not @show},
           %{hide: JS.exec("data-cancel", to: "##{@id}"), show: show_dialog(@id)}}
        )}
      <% end %>

      <.content
        :if={@content == []}
        role={if @alert, do: "alertdialog", else: "dialog"}
        aria-modal="true"
        class={if @is_unstyled, do: @class, else: @size_class}
        id={"#{@id}-content"}
        hidden={not @show}
        is_unstyled={@is_unstyled}
        title={@title}
        show_close={@show_close}
        hide={JS.exec("data-cancel", to: "##{@id}")}
        tabindex="-1"
        {@rest}
      >
        {render_slot(@inner_block, %{
          hide: JS.exec("data-cancel", to: "##{@id}"),
          show: show_dialog(@id)
        })}
        <:footer>
          {render_slot(@footer, %{
            hide: JS.exec("data-cancel", to: "##{@id}"),
            show: show_dialog(@id)
          })}
        </:footer>
      </.content>
    </div>
    """
  end

  def hide_dialog(id) do
    JS.set_attribute({"hidden", true}, to: "##{id}-backdrop")
    |> JS.set_attribute({"hidden", true}, to: "##{id}-content")
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  def show_dialog(id) do
    JS.push_focus()
    |> JS.remove_attribute("hidden", to: "##{id}-backdrop")
    |> JS.remove_attribute("hidden", to: "##{id}-content")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end
end
