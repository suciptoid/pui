%{
  title: "Tooltip",
  description: "Lightweight hover and focus hints with Floating UI placement.",
  group: "Overlays",
  order: 2,
  icon: "hero-chat-bubble-left-right"
}
---

The Tooltip component provides lightweight hover and focus hints with Floating UI positioning. Use it for short, contextual guidance that should stay attached to a trigger element.

## Import

```elixir
use PUI
# or
import PUI.Popover
```

## Basic Tooltip

Display a tooltip on hover or focus:

```heex
<.tooltip>
  <.button variant="outline">Hover me</.button>
  <:tooltip>This is a helpful tooltip</:tooltip>
</.tooltip>
```

## Placement

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

## Rich Content

Tooltips can contain short formatted content:

```heex
<.tooltip id="details-tooltip" placement="bottom">
  <.button variant="outline">Hover for details</.button>
  <:tooltip>
    <div class="w-56 space-y-2">
      <p class="text-sm font-medium">Tooltip content</p>
      <p class="text-xs text-muted-foreground">
        Keep tooltips short and contextual so they remain easy to scan.
      </p>
    </div>
  </:tooltip>
</.tooltip>
```

## Unstyled / Headless

Use `variant="unstyled"` when you want to provide all tooltip classes yourself:

```heex
<.tooltip
  variant="unstyled"
  class="rounded bg-zinc-950 px-3 py-1.5 text-sm text-white
    aria-hidden:pointer-events-none aria-hidden:opacity-0
    invisible not-aria-hidden:visible not-aria-hidden:opacity-100"
>
  <button type="button" class="underline">Hover me</button>
  <:tooltip>Custom tooltip styling</:tooltip>
</.tooltip>
```

## API Reference

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
