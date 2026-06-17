%{
  title: "Toast & Flash",
  description: "Toast notification system with animations, positioning, and auto-dismiss.",
  group: "Feedback",
  order: 1,
  icon: "hero-speaker-wave"
}
---

PUI's Flash system provides a full-featured toast notification system with stacking, auto-dismiss, multiple positions, and LiveComponent support. It's built as an enhanced replacement for Phoenix's built-in flash messages.

## Import

```elixir
use PUI
# or
import PUI.Flash
```

## Basic Usage

Add the `flash_group` component to your layout to enable flash messages:

```heex
<.flash_group flash={@flash} />
```

## Sending Flash Messages

Send flash messages from your LiveView event handlers:

```elixir
def handle_event("save", _params, socket) do
  PUI.Flash.send_flash("Changes saved successfully!")
  {:noreply, socket}
end
```

### Phoenix Preset Toasts

Phoenix flash keys such as `:success`, `:error`, `:info`, and `:warning` are
automatically rendered as compact pill-shaped toasts with a type-colored icon:

```elixir
def handle_event("save", _params, socket) do
  {:noreply, put_flash(socket, :success, "Changes saved!")}
end

def handle_event("delete", _params, socket) do
  {:noreply, put_flash(socket, :error, "Could not delete item")}
end

def handle_event("warn", _params, socket) do
  {:noreply, put_flash(socket, :warning, "Session expires soon")}
end

def handle_event("notify", _params, socket) do
  {:noreply, put_flash(socket, :info, "New update available")}
end
```

You can also trigger the same preset toast style through `send_flash`:

```elixir
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :success,
  message: "Connected!"
})
```

Preset toasts use a dark pill-shaped container, truncate to one line, and show a
visible close button. Messages sent without a preset type keep the standard flash
UI.

### With Options

```elixir
# Success message
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :info,
  message: "Item created!",
  duration: 3000
})

# Error message
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :error,
  message: "Failed to save"
})
```

## Custom Content

Send HEEx content in flashes. When `message` is a HEEx template, the custom
markup overrides the preset toast styling. Plain-string messages with a preset
type still render as the compact built-in toast with a type-colored icon:

```elixir
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :success,
  message: ~H|<div class="flex items-center gap-2">
    <.icon name="hero-check-circle" class="size-5" />
    <span>Success!</span>
  </div>|
})
```

### Custom Flash with Async Update

You can send a custom flash with rich HEEx content and update it later by ID.
This is useful for showing progress and then replacing it with a result:

```elixir
def handle_event("dispatch_ping", _params, socket) do
  server = socket.assigns.server

  message = ~H"""
  <div class="flex items-center gap-2">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24" height="24" viewBox="0 0 24 24"
      fill="none" stroke="currentColor" stroke-width="2"
      stroke-linecap="round" stroke-linejoin="round"
      class="animate-spin text-foreground size-5"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none" />
      <path d="M12 6l0 -3" />
      <path d="M16.25 7.75l2.15 -2.15" />
      <path d="M18 12l3 0" />
      <path d="M16.25 16.25l2.15 2.15" />
      <path d="M12 18l0 3" />
      <path d="M7.75 16.25l-2.15 2.15" />
      <path d="M6 12l-3 0" />
      <path d="M7.75 7.75l-2.15 -2.15" />
    </svg>
    <div>Connecting to server...</div>
  </div>
  """

  PUI.Flash.send_flash(%PUI.Flash.Message{
    id: "ping-#{server.id}",
    message: message,
    duration: -1
  })

  parent = self()

  Task.async(fn ->
    message =
      case perform_ping(server.id) do
        {:ok, %{status: :up}} ->
          ~H"""
          <div class="flex items-center gap-2">
            <.icon name="hero-check-circle" class="size-6 text-green-600" />
            <div>Server connected</div>
          </div>
          """

        _ ->
          ~H"""
          <div class="flex items-center gap-2">
            <.icon name="hero-x-circle" class="size-6 text-red-600" />
            <div>Server unreachable</div>
          </div>
          """
      end

    PUI.Flash.update_flash(parent, %PUI.Flash.Message{
      id: "ping-#{server.id}",
      message: message,
      duration: 5
    })
  end)

  {:noreply, socket}
end
```

Set `duration: -1` to keep the flash open until you explicitly update or dismiss it.

When `message` is a HEEx template, the custom markup overrides the preset toast
styling. Plain-string messages with a preset type still render as the compact
built-in toast with a type-colored icon.

<AppWeb.DocsDemo.custom_flash_demo ping_state={@ping_state} />

## Positioning

Flash groups support six positions:

```heex
<.flash_group flash={@flash} position="top-center" />
<.flash_group flash={@flash} position="top-left" />
<.flash_group flash={@flash} position="top-right" />
<.flash_group flash={@flash} position="bottom-center" />
<.flash_group flash={@flash} position="bottom-left" />
<.flash_group flash={@flash} position="bottom-right" />
```

<AppWeb.DocsDemo.flash_demo flash_position={@flash_position} toast_count={@toast_count} />

## Auto-Dismiss

Control auto-dismiss timing (in milliseconds):

```heex
<!-- Dismiss after 3 seconds -->
<.flash_group flash={@flash} auto_dismiss={3000} />

<!-- Dismiss after 10 seconds -->
<.flash_group flash={@flash} auto_dismiss={10000} />
```

## Message Limit

Limit the number of visible messages:

```heex
<.flash_group flash={@flash} limit={3} />
```

## Live Component Mode

Enable LiveComponent mode for richer flash management:

```heex
<.flash_group flash={@flash} live={true} />
```

## Closeable

Control whether flash messages show a close button:

```heex
<.flash_group flash={@flash} show_close={false} />
```

## API Reference

### FlashGroup Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `flash` | `map` | **required** | The flash map from socket assigns |
| `live` | `boolean` | `false` | Enable LiveComponent mode |
| `limit` | `integer` | `5` | Max visible messages |
| `position` | `string` | `"top-center"` | Position: `"top-left"`, `"top-right"`, `"top-center"`, `"bottom-left"`, `"bottom-right"`, `"bottom-center"` |
| `auto_dismiss` | `integer` | `5000` | Auto-dismiss time in ms |
| `show_close` | `boolean` | `true` | Show close button |

### Flash Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | — | Flash message ID |
| `position` | `string` | `"top-center"` | Position variant |
| `type` | `atom` | `:info` | Message type: `:info`, `:success`, `:warning`, `:error` |
| `preset` | `boolean` | `false` | Use compact preset toast styling |
| `class` | `string` | `""` | Additional CSS classes |
| `show_close` | `boolean` | `true` | Show close button |
