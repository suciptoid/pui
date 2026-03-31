%{
  title: "Dialog",
  description: "Modal dialogs for confirmations, forms, and complex interactions.",
  group: "Overlays",
  order: 0,
  icon: "hero-squares-2x2"
}
---

The Dialog component provides accessible modal dialogs built on the native `<dialog>` element. It supports server-controlled visibility, multiple sizes, alert dialogs, and custom content with backdrop handling.

## Import

```elixir
use PUI
# or
import PUI.Dialog
```

## Basic Usage

Dialogs require an `id` and can be shown/hidden programmatically:

```heex
<.button phx-click={PUI.Dialog.show_dialog("my-dialog")}>
  Open Dialog
</.button>

<.dialog id="my-dialog">
  <:content>
    <h2 class="text-lg font-semibold">Dialog Title</h2>
    <p class="mt-2 text-muted-foreground">
      This is the dialog content.
    </p>
    <div class="mt-4 flex justify-end gap-2">
      <.button variant="outline"
        phx-click={PUI.Dialog.hide_dialog("my-dialog")}>
        Cancel
      </.button>
      <.button>Confirm</.button>
    </div>
  </:content>
</.dialog>
```

<AppWeb.DocsDemo.dialog_basic_demo />

## Server-Controlled

Control dialog visibility from the server with the `show` attribute:

```heex
<.dialog id="server-dialog" show={@show_dialog}>
  <:content>
    <p>This dialog is controlled by server state.</p>
  </:content>
</.dialog>
```

```elixir
def handle_event("open", _, socket) do
  {:noreply, assign(socket, show_dialog: true)}
end
```

## Sizes

Dialogs come in four sizes:

```heex
<.dialog id="sm-dialog" size="sm">...</.dialog>
<.dialog id="md-dialog" size="md">...</.dialog>  <!-- default -->
<.dialog id="lg-dialog" size="lg">...</.dialog>
<.dialog id="xl-dialog" size="xl">...</.dialog>
```

<AppWeb.DocsDemo.dialog_sizes_demo />

## Alert Dialog

Alert dialogs require explicit user action and cannot be dismissed by clicking the backdrop:

```heex
<.dialog id="alert-dialog" alert={true}>
  <:content>
    <h2 class="text-lg font-semibold text-destructive">
      Delete Account?
    </h2>
    <p class="mt-2">This action cannot be undone.</p>
    <div class="mt-4 flex justify-end gap-2">
      <.button variant="outline"
        phx-click={PUI.Dialog.hide_dialog("alert-dialog")}>
        Cancel
      </.button>
      <.button variant="destructive" phx-click="delete_account">
        Delete
      </.button>
    </div>
  </:content>
</.dialog>
```

<AppWeb.DocsDemo.dialog_alert_demo />

## With Trigger Slot

Use the `trigger` slot for inline trigger buttons:

```heex
<.dialog id="trigger-dialog">
  <:trigger>
    <.button>Open</.button>
  </:trigger>
  <:content>
    <p>Dialog with trigger slot.</p>
  </:content>
</.dialog>
```

## Unstyled / Headless

```heex
<.dialog id="headless" variant="unstyled">
  <:content>
    <div class="my-custom-dialog-panel">
      Custom styled dialog content
    </div>
  </:content>
</.dialog>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | **required** | Unique identifier for the dialog |
| `show` | `boolean` | `false` | Server-controlled visibility |
| `alert` | `boolean` | `false` | Alert dialog mode (no backdrop dismiss) |
| `size` | `string` | `"md"` | Dialog size: `"sm"`, `"md"`, `"lg"`, `"xl"` |
| `on_cancel` | `JS` | `%JS{}` | JS command to run on cancel |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional CSS classes |

### Slots

| Name | Required | Description |
|------|----------|-------------|
| `trigger` | — | Inline trigger element |
| `content` | — | Dialog content |
| `inner_block` | — | Alternative to named slots |
