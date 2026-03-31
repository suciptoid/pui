%{
title: "Popover",
description: "Floating content panels built with Floating UI for precise positioning and dismissal behavior.",
  group: "Overlays",
  order: 1,
  icon: "hero-squares-2x2"
}
---

The Popover component provides floating content panels built with Floating UI for precise, collision-aware positioning. Use `popover_base` when you need a low-level primitive for custom popover UIs or menus.

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
  <:trigger class="inline-flex items-center rounded-md border px-4 py-2 text-sm font-medium">
    Show Info
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

<AppWeb.DocsDemo.popover_demo />

## Unstyled / Headless

Use `variant="unstyled"` for complete styling control:

```heex
<.popover_base id="custom-popover" variant="unstyled">
  <:trigger class="my-trigger">Open</:trigger>
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
