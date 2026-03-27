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

### With Options

```elixir
# Success message
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :info,
  message: "Item created!",
  icon: "hero-check-circle",
  duration: 3000
})

# Error message
PUI.Flash.send_flash(%PUI.Flash.Message{
  type: :error,
  message: "Failed to save",
  icon: "hero-exclamation-circle"
})
```

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
| `class` | `string` | `""` | Additional CSS classes |
| `show_close` | `boolean` | `true` | Show close button |
