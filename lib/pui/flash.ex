defmodule PUI.Flash do
  @moduledoc """
  Toast notification system for LiveView applications.

  ## Basic Setup

  Add the flash group to your layout:

      <PUI.Flash.flash_group flash={@flash} />

  For LiveView pages with dynamic flashes:

      <PUI.Flash.flash_group flash={@flash} live={true} />

  ## Sending Flashes

  From a LiveView:

      PUI.Flash.send_flash("Operation completed successfully!")

  With custom options:

      PUI.Flash.send_flash(%PUI.Flash.Message{
        type: :success,
        message: "Saved!",
        duration: 8,
        class: "border-green-500"
      })

  ## Phoenix Preset Toasts

  Flash keys commonly used by Phoenix (`:success`, `:error`, `:info`, `:warning`)
  are rendered as compact pill-shaped toasts with a type-colored icon. They are
  positioned at `top-center` by default, show a visible close button, and truncate
  to a single line.

      {:noreply, put_flash(socket, :success, "Changes saved!")}
      {:noreply, put_flash(socket, :error, "Could not save changes")}
      {:noreply, put_flash(socket, :warning, "Session expires soon")}
      {:noreply, put_flash(socket, :info, "New update available")}

  You can also trigger the preset toast style through `send_flash` by setting
  one of those types:

      PUI.Flash.send_flash(%PUI.Flash.Message{
        type: :success,
        message: "Connected!"
      })

  ## Positioning

  Position the flash container in different corners:

      <PUI.Flash.flash_group flash={@flash} position="top-right" />
      <PUI.Flash.flash_group flash={@flash} position="top-center" />
      <PUI.Flash.flash_group flash={@flash} position="bottom-left" />

  Available positions: `top-left`, `top-center`, `top-right`,
  `bottom-left`, `bottom-center`, `bottom-right`

  ## Custom Content

  Send HEEx content in flashes:

      PUI.Flash.send_flash(~H|<div class="flex items-center gap-2">
        <.icon name="hero-check-circle" class="size-5" />
        <span>Success!</span>
      </div>|)

  ## Updating Flashes

  Update an existing flash by ID:

      PUI.Flash.update_flash(%PUI.Flash.Message{
        id: "my-flash",
        message: "Updated!"
      })

  ## Configuration

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `flash` | `map` | required | Phoenix flash map |
  | `live` | `boolean` | `false` | Enable LiveComponent for dynamic updates |
  | `position` | `string` | `"top-center"` | Container position |
  | `limit` | `integer` | `5` | Maximum number of visible flashes |
  | `auto_dismiss` | `integer` | `5000` | Auto-dismiss delay in ms |
  | `show_close` | `boolean` | `true` | Show close button |

  ## Message Struct

  Create flash messages with the `Message` struct:

      %PUI.Flash.Message{
        message: "Hello!",           # Required
        type: nil,                    # :info, :success, :warning, :error, or nil
        preset: false,                # True for Phoenix preset toast styling
        duration: 5,                  # Seconds until auto-dismiss
        auto_dismiss: true,           # Auto-dismiss enabled
        dismissable: true,            # Allow manual dismiss
        show_close: true,             # Show close button
        class: ""                     # Additional CSS classes
      }
  """

  use Phoenix.LiveComponent

  defmodule Message do
    defstruct id: nil,
              icon: nil,
              message: nil,
              type: nil,
              preset: false,
              duration: 5,
              auto_dismiss: true,
              dismissable: true,
              class: "",
              show_close: true

    def new(message \\ "") do
      %__MODULE__{
        id: "fl#{System.unique_integer()}",
        message: message
      }
    end
  end

  @default_container_id "flash-container"
  @default_position "top-center"
  @default_limit 5
  @preset_types [:info, :success, :warning, :error]

  defp preset_type?(type) when type in @preset_types, do: true
  defp preset_type?(_), do: false

  def mount(socket) do
    socket = socket |> stream(:flashs, [])
    {:ok, socket}
  end

  def update(%{from: :send_flash, flash: flash}, socket) do
    socket = stream_insert(socket, :flashs, flash, limit: socket.assigns.limit, at: 0)

    {:ok, socket}
  end

  def update(%{from: :update_flash, flash: flash}, socket) do
    socket =
      stream_insert(socket, :flashs, flash, limit: socket.assigns.limit, at: 0, update_only: true)

    {:ok, socket}
  end

  def update(assigns, socket) do
    flash = map_flash(assigns.flash)

    limit = Map.get(assigns, :limit, @default_limit)
    position = Map.get(assigns, :position, @default_position)

    socket =
      socket
      |> assign(position: position, limit: limit, id: assigns.id)
      |> then(fn socket ->
        if flash != [] do
          Enum.reduce(flash, socket, fn item, sock ->
            stream_insert(sock, :flashs, item, limit: limit, at: 0)
          end)
        else
          socket
        end
      end)

    {:ok, socket}
  end

  def handle_event("dismiss_flash", %{"id" => id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :flashs, id)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.container
        id="flashs-stream"
        position={@position}
        phx-update="stream"
      >
        <.flash
          :for={{id, flash} <- @streams.flashs}
          id={id}
          data-flash-id={flash.id}
          data-duration={flash.duration}
          position={@position}
          type={flash.type}
          preset={flash.preset}
          class={flash.class}
          show_close={flash.show_close}
        >
          {flash.message}
        </.flash>
      </.container>
    </div>
    """
  end

  @doc """
  Use .flash_group to place flash container in your layout.

  If you want to use in liveview page, pass option `live={true}`

  example:
  ```elixir
  <PUI.Flash.flash_group flash={@flash} live={true}>
  ```

  """
  attr :flash, :map, required: true
  attr :live, :boolean, default: false
  attr :limit, :integer, default: 5

  attr :position, :string,
    default: @default_position,
    values: [
      "top-left",
      "top-right",
      "top-center",
      "bottom-left",
      "bottom-right",
      "bottom-center"
    ]

  attr :auto_dismiss, :integer, default: 5000
  attr :show_close, :boolean, default: true

  def flash_group(assigns) do
    assigns =
      assign_new(assigns, :id, fn ->
        @default_container_id
      end)

    if assigns[:live] do
      ~H"""
      <.live_component
        id={@id}
        module={PUI.Flash}
        limit={@limit}
        flash={@flash}
        position={@position}
      />
      """
    else
      flash = map_flash(assigns[:flash])
      assigns = assign(assigns, :flashs, flash)

      ~H"""
      <.container id={@id} position={@position}>
        <PUI.Flash.flash
          :for={flash <- @flashs}
          id={flash.id}
          data-flash-id={flash.id}
          position={@position}
          type={flash.type}
          preset={flash.preset}
        >
          {flash.message}
        </PUI.Flash.flash>
      </.container>
      """
    end
  end

  @doc """
  Individual flash message component.

  When `preset` is `true` (set automatically for Phoenix flash keys such as
  `:success`, `:error`, `:info`, and `:warning`), the message renders as a
  compact toast with a type-colored icon and a dark pill-shaped container.
  """
  attr :id, :string
  attr :position, :string, default: @default_position
  attr :type, :atom, default: :info
  attr :preset, :boolean, default: false
  attr :class, :string, default: ""
  attr :show_close, :boolean, default: true
  attr :rest, :global
  slot :inner_block

  def flash(%{preset: true} = assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      aria-hidden="true"
      data-position={@position}
      data-preset="true"
      class={[
        "bg-black/95 text-white text-xs font-medium",
        "w-fit max-w-[75vw] min-w-0 rounded-full shadow-lg",
        "flex items-center gap-2 pl-2.5 pr-8 py-2",
        "transition-all duration-400 opacity-0",
        "absolute left-0 right-0 data-[position^='top-']:top-0 data-[position^='bottom-']:bottom-0",
        "m-auto z-[calc(1000-var(--flash-index))] not-aria-hidden:translate-y-[calc(var(--flash-offset-y))] not-aria-hidden:opacity-100",
        @class
      ]}
      {@rest}
    >
      <.flash_icon type={@type} />

      <span class="truncate">
        {render_slot(@inner_block)}
      </span>

      <button
        :if={@show_close}
        data-close
        class="absolute right-2 top-1/2 -translate-y-1/2 p-0.5 flex items-center justify-center rounded-full text-white/60 hover:text-white hover:bg-white/10"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="size-3"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    """
  end

  def flash(assigns) do
    ~H"""
    <div
      id={@id}
      role="alert"
      aria-hidden="true"
      data-position={@position}
      class={[
        "bg-background text-secondary-foreground text-sm group",
        "w-full min-w-[300px] rounded-md border border-border py-3 px-4 shadow-sm",
        "transition-all duration-400 opacity-0",
        "absolute left-0 right-0 data-[position^='top-']:top-0 data-[position^='bottom-']:bottom-0",
        "m-auto z-[calc(1000-var(--flash-index))] not-aria-hidden:translate-y-[calc(var(--flash-offset-y))] not-aria-hidden:opacity-100",
        @class
      ]}
      {@rest}
    >
      <div class="flash-content overflow-hidden relative">
        {render_slot(@inner_block)}
      </div>

      <button
        :if={@show_close}
        data-close
        class="absolute hidden group-hover:flex top-1.5 right-1.5 p-0.5 w-fit items-center justify-center rounded-sm hover:bg-popover/90"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    """
  end

  attr :type, :atom, required: true

  defp flash_icon(%{type: :success} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 text-green-500"
    >
      <circle cx="12" cy="12" r="10" /><path d="m9 12 2 2 4-4" />
    </svg>
    """
  end

  defp flash_icon(%{type: :error} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 text-red-500"
    >
      <circle cx="12" cy="12" r="10" /><path d="m15 9-6 6" /><path d="m9 9 6 6" />
    </svg>
    """
  end

  defp flash_icon(%{type: :warning} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 text-yellow-500"
    >
      <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z" />
      <path d="M12 9v4" /><path d="M12 17h.01" />
    </svg>
    """
  end

  defp flash_icon(%{type: :info} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 text-blue-500"
    >
      <circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />
    </svg>
    """
  end

  defp flash_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="size-4 shrink-0 text-blue-500"
    >
      <circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />
    </svg>
    """
  end

  @doc """
  Flash container with positioning support.
  """
  slot :inner_block
  attr :position, :string, default: @default_position
  attr :rest, :global

  def container(assigns) do
    position_classes =
      case assigns.position do
        "top-right" -> "top-[1rem] right-[1rem] "
        "top-center" -> "top-[1rem] left-1/2 -translate-x-1/2 "
        "top-left" -> "top-[1rem] left-[1rem] "
        "bottom-right" -> "bottom-[1rem] right-[1rem] "
        "bottom-center" -> "bottom-[1rem] left-1/2 -translate-x-1/2 "
        "bottom-left" -> "bottom-[1rem] left-[1rem]"
        _ -> "bottom-[1rem] right-[1rem]"
      end

    assigns = assign(assigns, :position_classes, position_classes)

    ~H"""
    <div
      data-position={@position}
      phx-hook="PUI.FlashGroup"
      class={[
        "fixed z-[1000] flex flex-col w-auto min-w-[300px]",
        @position_classes
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp map_flash(flash) do
    Enum.map(flash, fn {key, value} -> %{key: key, value: value} end)
    |> Enum.filter(fn f ->
      key =
        case f.key do
          k when is_atom(k) -> Atom.to_string(k)
          k when is_binary(k) -> k
          _ -> ""
        end

      String.starts_with?(key, ["error", "info", "flash", "toast", "success", "warning"])
    end)
    |> Enum.map(fn f ->
      id = "fl#{System.unique_integer([:positive])}"
      type = normalize_flash_key(f.key)
      preset = preset_type?(type)

      case f.value do
        v when is_binary(v) ->
          %Message{id: id, type: type, preset: preset, message: v}

        {_, message} ->
          %Message{id: id, type: type, preset: preset, message: message}

        _ ->
          %Message{id: id, type: type, preset: preset, message: f.value}
      end
    end)
  end

  defp normalize_flash_key(key) when is_atom(key), do: key

  defp normalize_flash_key(key) when is_binary(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> nil
  end

  defp normalize_flash_key(_), do: nil

  def send_flash(pid \\ self(), message)

  def send_flash(pid, %Message{} = flash) do
    flash =
      flash
      |> Map.update(:id, "fl-#{System.unique_integer([:positive])}", fn v ->
        if is_nil(v), do: "fl-#{System.unique_integer([:positive])}", else: v
      end)
      |> maybe_mark_preset()

    Phoenix.LiveView.send_update(pid, PUI.Flash,
      id: @default_container_id,
      flash: flash,
      from: :send_flash
    )

    {:ok, flash}
  end

  def send_flash(pid, message) do
    send_flash(pid, %Message{id: "fl-#{System.unique_integer([:positive])}", message: message})
  end

  defp maybe_mark_preset(%Message{type: type} = flash) when type in @preset_types do
    %{flash | preset: true}
  end

  defp maybe_mark_preset(flash), do: flash

  def update_flash(pid \\ self(), %Message{} = flash) do
    Phoenix.LiveView.send_update(pid, PUI.Flash,
      id: @default_container_id,
      flash: flash,
      from: :update_flash
    )

    {:ok, flash}
  end
end
