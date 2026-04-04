%{
  title: "Dialog",
  description: "Modal dialogs for confirmations, forms, and complex interactions.",
  group: "Overlays",
  order: 0,
  icon: "hero-squares-2x2"
}
---

The Dialog component provides accessible modal dialogs built on the native `<dialog>` element. It supports built-in titles, an optional close button, fixed footers, server-controlled visibility, multiple sizes, and a scrollable body when content exceeds the viewport.

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

<.dialog id="my-dialog" title="Dialog Title">
  <p class="text-muted-foreground">
    This is the dialog content.
  </p>
  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline"
        phx-click={PUI.Dialog.hide_dialog("my-dialog")}>
        Cancel
      </.button>
      <.button>Confirm</.button>
    </div>
  </:footer>
</.dialog>
```

<AppWeb.DocsDemo.dialog_basic_demo />

## Title and Close Button

Use `title` to render a built-in heading and `show_close` to control the header action:

```heex
<.dialog id="profile-dialog" title="Edit profile">
  <p>Update your account details.</p>
  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline">Cancel</.button>
      <.button>Save</.button>
    </div>
  </:footer>
</.dialog>

<.dialog id="checkout-dialog" title="Review order" show_close={false}>
  <p>Disable the close button when you need a custom action row.</p>
  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline">Back</.button>
      <.button>Continue</.button>
    </div>
  </:footer>
</.dialog>
```

## Scrollable Body and Fixed Footer

The default dialog keeps the title and footer visible while the main content scrolls automatically:

```heex
<.dialog id="activity-dialog" title="Recent activity" size="lg">
  <div class="space-y-4">
    <p :for={index <- 1..12}>
      Activity #{index}: This content scrolls inside the dialog body.
    </p>
  </div>

  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline">Close</.button>
      <.button>Save changes</.button>
    </div>
  </:footer>
</.dialog>
```

<AppWeb.DocsDemo.dialog_scroll_demo />

## Server-Controlled

Control dialog visibility from the server with the `show` attribute:

```heex
<.dialog id="server-dialog" show={@show_dialog}>
  <p>This dialog is controlled by server state.</p>
  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline" phx-click="close">Cancel</.button>
      <.button>Continue</.button>
    </div>
  </:footer>
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
<.dialog id="alert-dialog" title="Delete Account?" alert={true}>
  <p class="mt-2">This action cannot be undone.</p>
  <:footer>
    <div class="flex justify-end gap-2">
      <.button variant="outline"
        phx-click={PUI.Dialog.hide_dialog("alert-dialog")}>
        Cancel
      </.button>
      <.button variant="destructive" phx-click="delete_account">
        Delete
      </.button>
    </div>
  </:footer>
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
  <p>Dialog with trigger slot.</p>
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
| `title` | `string` | `nil` | Optional built-in title for the default dialog header |
| `show_close` | `boolean` | `true` | Show the built-in close button on default dialogs |
| `on_cancel` | `JS` | `%JS{}` | JS command to run on cancel |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional CSS classes |

### Slots

| Name | Required | Description |
|------|----------|-------------|
| `trigger` | — | Inline trigger element |
| `footer` | — | Optional fixed footer for actions in the default layout |
| `content` | — | Override the entire content container |
| `inner_block` | — | Main dialog body content |
