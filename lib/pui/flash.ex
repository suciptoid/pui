defmodule PUI.Flash do
  @moduledoc """
  Toast notification system for LiveView applications.

  ## Basic Setup

  Add the flash group to your layout:

      <PUI.Flash.flash_group flash={@flash} />

  For LiveView pages with dynamically-triggered flashes:

      <PUI.Flash.flash_group flash={@flash} live={true} />

  ## Sending Flashes

  From a LiveView:

      PUI.Flash.send_flash("Operation completed successfully!")

  Override the layout position for an individual trigger:

      PUI.Flash.send_flash("Copied!", position: "bottom-right")

  The same position can be stored on a message when it will be updated later:

      PUI.Flash.send_flash(%PUI.Flash.Message{
        type: :success,
        message: "Saved!",
        position: "top-right"
      })

  ## Phoenix Preset Toasts

  Flash keys commonly used by Phoenix (`:success`, `:error`, `:info`, `:warning`)
  are rendered as constrained card toasts with a type-colored icon. Their
  messages wrap within the card while the icon and close button remain fixed.
  They use the group position unless a `PUI.Flash.Message` is sent directly.

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

  ## Positioning and Stacking

  Position the default flash group in different corners:

      <PUI.Flash.flash_group flash={@flash} position="top-right" />
      <PUI.Flash.flash_group flash={@flash} position="top-center" />
      <PUI.Flash.flash_group flash={@flash} position="bottom-left" />

  Available positions: `top-left`, `top-center`, `top-right`,
  `bottom-left`, `bottom-center`, `bottom-right`.

  Multiple flashes remain expanded by default. Set `stacked` to `true` to
  collapse them into a stack that expands on hover or focus:

      <PUI.Flash.flash_group flash={@flash} stacked />

  Collapsed stacks show at most three indicators behind the front message;
  additional messages remain available and appear when the stack expands.

  ## Custom Content

  Send HEEx content in flashes. When `message` is a HEEx template, the custom
  markup overrides the preset toast styling:

      PUI.Flash.send_flash(%PUI.Flash.Message{
        type: :success,
        message: ~H|<div class="flex items-center gap-2">
          <.icon name="hero-check-circle" class="size-5" />
          <span>Success!</span>
        </div>|,
        position: "bottom-right"
      })

  Plain-string messages with a preset type still render as the built-in card
  toast with a type-colored icon.

  ## Updating Flashes

  Update an existing flash by ID:

      PUI.Flash.update_flash(%PUI.Flash.Message{
        id: "my-flash",
        message: "Updated!"
      })

  ## Timeout and Dismissal

  `Message.duration` is measured in seconds and defaults to the group timeout.
  `duration: -1` keeps a message open. `auto_dismiss: false` disables its timer.
  The group-level `auto_dismiss` value is measured in milliseconds:

      <PUI.Flash.flash_group flash={@flash} auto_dismiss={3000} />

  ## Configuration

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `flash` | `map` | required | Phoenix flash map |
  | `live` | `boolean` | `false` | Enable LiveComponent for dynamic updates |
  | `id` | `string` | `"flash-container"` | Unique flash group ID |
  | `position` | `string` | `"top-center"` | Fallback container position |
  | `stacked` | `boolean` | `false` | Collapse messages into an expandable stack |
  | `limit` | `integer` | `3` | Maximum number of mounted flashes |
  | `auto_dismiss` | `integer \| false` | `5000` | Fallback auto-dismiss delay in milliseconds; `false` disables it |
  | `show_close` | `boolean` | `true` | Show close buttons |

  ## Message Struct

  Create flash messages with the `Message` struct:

      %PUI.Flash.Message{
        message: "Hello!",           # Required
        type: nil,                    # :info, :success, :warning, :error, or nil
        position: nil,                # Uses the group position when nil
        preset: false,                # True for Phoenix preset toast styling
        duration: nil,                # Seconds; nil uses the group timeout
        auto_dismiss: true,           # Auto-dismiss enabled
        dismissable: true,            # Allow manual dismissal
        show_close: true,             # Show the close button when the group allows it
        class: ""                     # Additional CSS classes
      }
  """

  use Phoenix.LiveComponent
  import PUI.Icon, only: [icon: 1]
  alias PUI.Flash.Message

  @default_container_id "flash-container"
  @default_position "top-center"
  @default_limit 3
  @default_timeout 5000
  @default_stacked false
  @positions [
    "top-left",
    "top-right",
    "top-center",
    "bottom-left",
    "bottom-right",
    "bottom-center"
  ]
  @preset_types [:info, :success, :warning, :error]

  defp preset_type?(type) when type in @preset_types, do: true
  defp preset_type?(_), do: false

  def mount(socket) do
    socket =
      socket
      |> stream_configure(:flashs, dom_id: &"flash-#{&1.id}")
      |> stream(:flashs, [])

    {:ok, socket}
  end

  def update(%{from: :send_flash, flash: flash}, socket) do
    limit = Map.get(socket.assigns, :limit, @default_limit)
    flash = prepare_message(flash)
    socket = stream_insert(socket, :flashs, flash, limit: limit, at: 0)

    {:ok, socket}
  end

  def update(%{from: :update_flash, flash: flash}, socket) do
    limit = Map.get(socket.assigns, :limit, @default_limit)
    flash = prepare_message(flash)

    socket =
      stream_insert(socket, :flashs, flash,
        limit: limit,
        at: 0,
        update_only: true
      )

    {:ok, socket}
  end

  def update(assigns, socket) do
    flash = map_flash(assigns.flash)
    limit = max(Map.get(assigns, :limit, @default_limit), 0)
    position = Map.get(assigns, :position, @default_position)
    stacked = Map.get(assigns, :stacked, @default_stacked)
    auto_dismiss = normalize_timeout(Map.get(assigns, :auto_dismiss, @default_timeout))
    show_close = Map.get(assigns, :show_close, true)
    id = Map.get(assigns, :id, @default_container_id)

    socket =
      assign(socket,
        position: position,
        stacked: stacked,
        limit: limit,
        auto_dismiss: auto_dismiss,
        show_close: show_close,
        id: id
      )

    socket =
      if flash == [] do
        socket
      else
        Enum.reduce(flash, socket, fn item, sock ->
          stream_insert(sock, :flashs, item, limit: limit, at: 0)
        end)
      end

    {:ok, socket}
  end

  def handle_event("dismiss_flash", %{"id" => id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :flashs, id)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.container
        id={"#{@id}-stream"}
        position={@position}
        stacked={@stacked}
        timeout={@auto_dismiss}
        live_component={true}
        phx-update="stream"
      >
        <.flash
          :for={{id, flash} <- @streams.flashs}
          id={id}
          data-flash-id={flash.id}
          data-flash-dom-id={id}
          position={effective_position(flash, @position)}
          duration={flash.duration}
          timeout={effective_timeout(flash, @auto_dismiss)}
          auto_dismiss={flash.auto_dismiss}
          type={flash.type}
          preset={flash.preset}
          class={flash.class}
          dismissable={flash.dismissable}
          show_close={show_close?(@show_close, flash)}
        >
          {flash.message}
        </.flash>
      </.container>
    </div>
    """
  end

  @doc """
  Renders the flash viewport and its messages.

  The group position is the fallback for Phoenix flash-map messages. A
  `PUI.Flash.Message` can override it with `position`.
  """
  attr :flash, :map, required: true
  attr :live, :boolean, default: false
  attr :id, :string, default: @default_container_id
  attr :limit, :integer, default: @default_limit

  attr :position, :string,
    default: @default_position,
    values: @positions

  attr :stacked, :boolean, default: @default_stacked
  attr :auto_dismiss, :any, default: @default_timeout
  attr :show_close, :boolean, default: true

  def flash_group(assigns) do
    if assigns.live do
      ~H"""
      <.live_component
        id={@id}
        module={PUI.Flash}
        limit={@limit}
        flash={@flash}
        position={@position}
        stacked={@stacked}
        auto_dismiss={@auto_dismiss}
        show_close={@show_close}
      />
      """
    else
      limit = max(assigns.limit, 0)
      timeout = normalize_timeout(assigns.auto_dismiss)
      flashs = assigns.flash |> map_flash() |> Enum.take(limit)
      assigns = assign(assigns, flashs: flashs, timeout: timeout)

      ~H"""
      <.container
        id={@id}
        position={@position}
        stacked={@stacked}
        timeout={@timeout}
      >
        <PUI.Flash.flash
          :for={flash <- @flashs}
          id={flash.id}
          data-flash-id={flash.id}
          position={effective_position(flash, @position)}
          duration={flash.duration}
          timeout={effective_timeout(flash, @timeout)}
          auto_dismiss={flash.auto_dismiss}
          type={flash.type}
          preset={flash.preset}
          class={flash.class}
          dismissable={flash.dismissable}
          show_close={show_close?(@show_close, flash)}
        >
          {flash.message}
        </PUI.Flash.flash>
      </.container>
      """
    end
  end

  @doc """
  Renders an individual flash message.

  `position` controls the message's named viewport position. The containing
  flash group supplies the fallback position and stack behavior.
  """
  attr :id, :string
  attr :position, :string, default: @default_position, values: @positions
  attr :type, :atom, default: :info
  attr :preset, :boolean, default: false
  attr :class, :string, default: ""
  attr :duration, :integer, default: nil
  attr :timeout, :integer, default: nil
  attr :auto_dismiss, :boolean, default: true
  attr :dismissable, :boolean, default: true
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
      data-duration={@duration}
      data-timeout={@timeout}
      data-auto-dismiss={to_string(@auto_dismiss)}
      class={[
        "pointer-events-auto flex items-center gap-3",
        "w-fit min-w-[200px] max-w-md",
        "rounded-xl border border-border bg-background px-4 py-3 pr-12",
        "text-sm text-secondary-foreground shadow-sm",
        "transition-[transform,opacity] duration-400 opacity-0",
        "absolute z-[calc(1000-var(--flash-index))] origin-top",
        "after:pointer-events-none after:absolute after:inset-x-0 after:content-[''] after:h-[10px]",
        "data-[expanded=true]:after:pointer-events-auto",
        "data-[position^='top-']:after:-bottom-[10px] data-[position^='bottom-']:after:-top-[10px]",
        "data-[position$='-center']:left-0 data-[position$='-center']:right-0 data-[position$='-center']:m-auto",
        "data-[position$='-right']:right-[1rem] data-[position$='-left']:left-[1rem]",
        "data-[position^='top-']:top-[1rem] data-[position^='bottom-']:bottom-[1rem]",
        "data-[visible=true]:opacity-100 data-[visible=true]:pointer-events-auto data-[visible=false]:pointer-events-none",
        "data-[position^='bottom-']:origin-bottom",
        @class
      ]}
      {@rest}
    >
      <.flash_icon type={@type} />

      <span class="flash-content min-w-0 flex-1 break-words leading-6 transition-opacity duration-200 data-[behind=true]:opacity-0 data-[expanded=true]:opacity-100 data-[behind=true]:pointer-events-none">
        {render_slot(@inner_block)}
      </span>

      <button
        :if={@show_close and @dismissable}
        type="button"
        data-close
        aria-label="Dismiss notification"
        class="absolute right-3 top-1/2 flex -translate-y-1/2 items-center justify-center rounded-md p-1 text-muted-foreground hover:bg-muted hover:text-foreground focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
      >
        <.icon name={:close} class="size-3" />
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
      data-duration={@duration}
      data-timeout={@timeout}
      data-auto-dismiss={to_string(@auto_dismiss)}
      class={[
        "pointer-events-auto bg-background text-secondary-foreground text-sm group",
        "w-fit min-w-[200px] max-w-md rounded-md border border-border py-3 px-4 shadow-sm",
        "transition-[transform,opacity] duration-400 opacity-0",
        "absolute z-[calc(1000-var(--flash-index))] origin-top",
        "after:pointer-events-none after:absolute after:inset-x-0 after:content-[''] after:h-[10px]",
        "data-[expanded=true]:after:pointer-events-auto",
        "data-[position^='top-']:after:-bottom-[10px] data-[position^='bottom-']:after:-top-[10px]",
        "data-[position$='-center']:left-0 data-[position$='-center']:right-0 data-[position$='-center']:m-auto",
        "data-[position$='-right']:right-[1rem] data-[position$='-left']:left-[1rem]",
        "data-[position^='top-']:top-[1rem] data-[position^='bottom-']:bottom-[1rem]",
        "data-[visible=true]:opacity-100 data-[visible=true]:pointer-events-auto data-[visible=false]:pointer-events-none",
        "data-[position^='bottom-']:origin-bottom",
        @class
      ]}
      {@rest}
    >
      <div class="flash-content relative overflow-hidden transition-opacity duration-200 data-[behind=true]:opacity-0 data-[expanded=true]:opacity-100 data-[behind=true]:pointer-events-none">
        {render_slot(@inner_block)}
      </div>

      <button
        :if={@show_close and @dismissable}
        type="button"
        data-close
        aria-label="Dismiss notification"
        class="absolute right-1.5 top-1.5 flex w-fit items-center justify-center rounded-sm p-0.5 opacity-0 hover:bg-popover/90 focus-visible:opacity-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring group-hover:opacity-100"
      >
        <.icon name={:close} class="size-4" />
      </button>
    </div>
    """
  end

  attr :type, :atom, required: true

  defp flash_icon(%{type: :success} = assigns) do
    ~H|<.icon name={:success} class="size-4 shrink-0 text-green-500" />|
  end

  defp flash_icon(%{type: :error} = assigns) do
    ~H|<.icon name={:error} class="size-4 shrink-0 text-red-500" />|
  end

  defp flash_icon(%{type: :warning} = assigns) do
    ~H|<.icon name={:warning} class="size-4 shrink-0 text-yellow-500" />|
  end

  defp flash_icon(%{type: :info} = assigns) do
    ~H|<.icon name={:info} class="size-4 shrink-0 text-blue-500" />|
  end

  defp flash_icon(assigns) do
    ~H|<.icon name={:info} class="size-4 shrink-0 text-blue-500" />|
  end

  @doc """
  Flash viewport with positioning and hook support.
  """
  attr :id, :string, required: true
  attr :position, :string, default: @default_position, values: @positions
  attr :stacked, :boolean, default: @default_stacked
  attr :timeout, :integer, default: @default_timeout
  attr :live_component, :boolean, default: false
  attr :rest, :global
  slot :inner_block

  def container(assigns) do
    ~H"""
    <div
      id={@id}
      data-position={@position}
      data-stacked={to_string(@stacked)}
      data-flash-timeout={@timeout}
      data-live-component={to_string(@live_component)}
      phx-hook="PUI.FlashGroup"
      class="pointer-events-none fixed inset-0 z-[1000]"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp map_flash(flash) do
    flash
    |> Enum.filter(fn {key, _value} -> allowed_flash_key?(key) end)
    |> Enum.map(fn {key, value} -> message_from_flash(key, value) end)
  end

  defp allowed_flash_key?(key) do
    key
    |> flash_key_string()
    |> String.starts_with?(["error", "info", "flash", "toast", "success", "warning"])
  end

  defp message_from_flash(key, %Message{} = message) do
    type = normalize_flash_key(key)

    message
    |> ensure_message_id(stable_flash_id(key))
    |> Map.update(:type, type, fn value -> if is_nil(value), do: type, else: value end)
    |> maybe_mark_preset()
  end

  defp message_from_flash(key, value) do
    id = stable_flash_id(key)
    type = normalize_flash_key(key)
    preset = preset_type?(type) and is_binary(value)

    case value do
      {position, message} when position in @positions ->
        %Message{
          id: id,
          type: type,
          position: position,
          preset: preset,
          message: message
        }

      {_, message} ->
        %Message{id: id, type: type, preset: preset, message: message}

      message ->
        %Message{id: id, type: type, preset: preset, message: message}
    end
  end

  defp flash_key_string(key) when is_atom(key), do: Atom.to_string(key)
  defp flash_key_string(key) when is_binary(key), do: key
  defp flash_key_string(_), do: ""

  defp stable_flash_id(key) do
    key = flash_key_string(key)
    safe_key = String.replace(key, ~r/[^a-zA-Z0-9_-]/u, "-")

    if safe_key == "" do
      "fl-#{System.unique_integer([:positive])}"
    else
      "fl-#{safe_key}"
    end
  end

  defp normalize_flash_key(key) when is_atom(key), do: key

  defp normalize_flash_key(key) when is_binary(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> nil
  end

  defp normalize_flash_key(_), do: nil

  def send_flash(message), do: send_flash(self(), message, [])

  def send_flash(message, opts) when is_list(opts) do
    send_flash(self(), message, opts)
  end

  def send_flash(pid, %Message{} = flash), do: send_flash(pid, flash, [])

  def send_flash(pid, message) do
    send_flash(pid, %Message{message: message}, [])
  end

  def send_flash(pid, %Message{} = flash, opts) when is_list(opts) do
    flash = prepare_message(flash, opts)

    Phoenix.LiveView.send_update(pid, PUI.Flash,
      id: @default_container_id,
      flash: flash,
      from: :send_flash
    )

    {:ok, flash}
  end

  def send_flash(pid, message, opts) when is_list(opts) do
    send_flash(pid, %Message{message: message}, opts)
  end

  defp maybe_mark_preset(%Message{type: type, message: message} = flash)
       when type in @preset_types and is_binary(message) do
    %{flash | preset: true}
  end

  defp maybe_mark_preset(flash), do: flash

  def update_flash(flash) when is_struct(flash, Message) do
    update_flash(self(), flash, [])
  end

  def update_flash(pid, %Message{} = flash) do
    update_flash(pid, flash, [])
  end

  def update_flash(pid, %Message{} = flash, opts) when is_list(opts) do
    flash = prepare_message(flash, opts)

    Phoenix.LiveView.send_update(pid, PUI.Flash,
      id: @default_container_id,
      flash: flash,
      from: :update_flash
    )

    {:ok, flash}
  end

  defp prepare_message(%Message{} = flash, opts \\ []) do
    opts = Keyword.validate!(opts, position: nil)
    position = Keyword.get(opts, :position) || flash.position

    flash
    |> ensure_message_id()
    |> Map.put(:position, normalize_position(position))
    |> maybe_mark_preset()
  end

  defp ensure_message_id(%Message{id: nil} = flash), do: ensure_message_id(flash, nil)
  defp ensure_message_id(%Message{} = flash), do: flash

  defp ensure_message_id(%Message{} = flash, fallback) do
    id = fallback || "fl-#{System.unique_integer([:positive])}"
    %{flash | id: id}
  end

  defp effective_position(%Message{position: position}, fallback) do
    case normalize_position(position) do
      nil -> fallback
      position -> position
    end
  end

  defp normalize_position(nil), do: nil
  defp normalize_position(position) when position in @positions, do: position

  defp normalize_position(position) do
    raise ArgumentError,
          "invalid flash position #{inspect(position)}; expected one of #{inspect(@positions)}"
  end

  defp effective_timeout(%Message{auto_dismiss: false}, _fallback), do: 0
  defp effective_timeout(%Message{duration: -1}, _fallback), do: 0

  defp effective_timeout(%Message{duration: duration}, _fallback)
       when is_integer(duration) and duration >= 0 do
    duration * 1000
  end

  defp effective_timeout(%Message{}, fallback), do: max(fallback, 0)

  defp normalize_timeout(false), do: 0
  defp normalize_timeout(timeout) when is_integer(timeout), do: max(timeout, 0)
  defp normalize_timeout(_), do: @default_timeout

  defp show_close?(group_show_close, %Message{} = flash) do
    group_show_close and flash.show_close and flash.dismissable
  end
end
