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
<PUI.Flash.flash_group flash={@flash} id="flash-basic-example" />
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
automatically rendered as constrained card toasts with a type-colored icon:

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

Preset toasts use a bounded card container, wrap long messages, and keep the icon
and visible close button in place. Messages sent without a preset type keep the
standard flash UI.

### With Options

```elixir
# Success message
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :info,
  message: "Item created!",
  duration: 3
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
styling. Plain-string messages with a preset type still render as the built-in
card toast with a type-colored icon.

<AppWeb.DocsDemo.custom_flash_demo ping_state={@ping_state} />

## Positioning

Flash groups support six positions:

```heex
<PUI.Flash.flash_group flash={@flash} id="flash-position-top-center" position="top-center" />
<PUI.Flash.flash_group flash={@flash} id="flash-position-top-left" position="top-left" />
<PUI.Flash.flash_group flash={@flash} id="flash-position-top-right" position="top-right" />
<PUI.Flash.flash_group flash={@flash} id="flash-position-bottom-center" position="bottom-center" />
<PUI.Flash.flash_group flash={@flash} id="flash-position-bottom-left" position="bottom-left" />
<PUI.Flash.flash_group flash={@flash} id="flash-position-bottom-right" position="bottom-right" />
```

The group position is the fallback for Phoenix flash-map messages. A trigger
can override it for a single message:

```elixir
PUI.Flash.send_flash("Copied!", position: "bottom-right")

PUI.Flash.send_flash(%PUI.Flash.Message{
  message: "Saved in a different stack",
  position: "top-right"
})
```

Messages with different positions are laid out in independent stacks in the
same full-screen viewport.

<AppWeb.DocsDemo.flash_demo flash_position={@flash_position} flash_stacked={@flash_stacked} toast_count={@toast_count} />

## Stacking

Messages remain expanded by default. Set `stacked` to collapse them into a
stack; hover or focus any visible stack indicator to expand all messages:

```heex
<PUI.Flash.flash_group flash={@flash} id="flash-stacking-example" stacked />
```

Collapsed stacks show at most three indicators behind the front message;
additional messages appear when the stack expands.

## Auto-Dismiss

Control auto-dismiss timing (in milliseconds):

```heex
<!-- Dismiss after 3 seconds -->
<PUI.Flash.flash_group flash={@flash} id="flash-timeout-short" auto_dismiss={3000} />

<!-- Dismiss after 10 seconds -->
<PUI.Flash.flash_group flash={@flash} id="flash-timeout-long" auto_dismiss={10000} />
```

## Message Limit

Limit the number of visible messages:

```heex
<PUI.Flash.flash_group flash={@flash} id="flash-limit-example" limit={3} />
```

## Live Component Mode

Enable LiveComponent mode for richer flash management:

```heex
<PUI.Flash.flash_group flash={@flash} id="flash-live-example" live={true} />
```

## Closeable

Control whether flash messages show a close button:

```heex
<PUI.Flash.flash_group flash={@flash} id="flash-close-example" show_close={false} />
```

## API Reference

### FlashGroup Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `flash` | `map` | **required** | The flash map from socket assigns |
| `live` | `boolean` | `false` | Enable LiveComponent mode |
| `limit` | `integer` | `5` | Max visible messages |
| `position` | `string` | `"top-center"` | Position: `"top-left"`, `"top-right"`, `"top-center"`, `"bottom-left"`, `"bottom-right"`, `"bottom-center"` |
| `stacked` | `boolean` | `false` | Collapse messages into an expandable stack |
| `auto_dismiss` | `integer \| false` | `5000` | Auto-dismiss time in ms; `false` disables it |
| `show_close` | `boolean` | `true` | Show close button |

### Flash Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | — | Flash message ID |
| `position` | `string` | `"top-center"` | Position variant |
| `type` | `atom` | `:info` | Message type: `:info`, `:success`, `:warning`, `:error` |
| `preset` | `boolean` | `false` | Use preset card toast styling |
| `class` | `string` | `""` | Additional CSS classes |
| `duration` | `integer` | `nil` | Message timeout in seconds; `-1` disables auto-dismiss |
| `auto_dismiss` | `boolean` | `true` | Disable auto-dismiss for this message when `false` |
| `dismissable` | `boolean` | `true` | Allow manual dismissal |
| `show_close` | `boolean` | `true` | Show close button |
