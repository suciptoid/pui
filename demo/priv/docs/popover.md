%{
  title: "Popover",
  description: "Floating popovers and tooltips using Floating UI for precise positioning.",
  group: "Overlays",
  order: 1,
  icon: "hero-squares-2x2"
}
---

The Popover component provides floating content panels and tooltips built with Floating UI for precise, collision-aware positioning. Use `base` for custom popover UIs and `tooltip` for simple hover tooltips.

## Import

```elixir
use PUI
# or
import PUI.Popover
```

## Base Popover

The `popover_base` component is a low-level building block with `trigger` and `popup` slots:

```heex
<.popover_base id="my-popover">
  <:trigger>
    <.button variant="outline">Show Info</.button>
  </:trigger>
  <:popup>
    <div class="p-4 space-y-2">
      <h3 class="font-semibold">Popover Title</h3>
      <p class="text-sm text-muted-foreground">
        This is some helpful information.
      </p>
    </div>
  </:popup>
</.popover_base>
```

## Tooltip

Display a tooltip on hover with configurable placement:

```heex
<.tooltip>
  <.button variant="outline">Hover me</.button>
  <:tooltip>This is a helpful tooltip</:tooltip>
</.tooltip>
```

### Placement

Tooltips support four placement options:

```heex
<.tooltip placement="top">
  <span>Top</span>
  <:tooltip>Top tooltip</:tooltip>
</.tooltip>

<.tooltip placement="bottom">
  <span>Bottom</span>
  <:tooltip>Bottom tooltip</:tooltip>
</.tooltip>

<.tooltip placement="left">
  <span>Left</span>
  <:tooltip>Left tooltip</:tooltip>
</.tooltip>

<.tooltip placement="right">
  <span>Right</span>
  <:tooltip>Right tooltip</:tooltip>
</.tooltip>
```

## Unstyled / Headless

Use `variant="unstyled"` for complete styling control:

```heex
<.popover_base id="custom-popover" variant="unstyled">
  <:trigger>
    <button class="my-trigger">Open</:button>
  </:trigger>
  <:popup class="my-popup-class">
    Custom styled content
  </:popup>
</.popover_base>
```

## API Reference

### Base Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | **required** | Unique identifier |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `hook` | `string` | `"Popover"` | JavaScript hook name |

### Base Slots

| Name | Required | Description |
|------|----------|-------------|
| `trigger` | — | Element that opens the popover (supports `class`, `role`) |
| `popup` | — | Floating content panel (supports `class`, `role`) |
| `inner_block` | — | Alternative to trigger slot |

### Tooltip Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | auto-generated | Unique identifier |
| `placement` | `string` | `"top"` | Position: `"top"`, `"bottom"`, `"left"`, `"right"` |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional CSS classes |

### Tooltip Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Trigger element |
| `tooltip` | ✓ | Tooltip content (supports `class`) |
