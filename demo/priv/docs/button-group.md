%{
  title: "Button Group",
  description: "Group related buttons together with shared styling and seamless borders.",
  group: "Actions",
  order: 1,
  icon: "hero-rectangle-group"
}
---

The Button Group component groups related buttons together with seamless borders and shared styling. It's ideal for toolbars, segmented controls, and split buttons.

## Import

```elixir
use PUI
# or
import PUI.ButtonGroup
```

## Basic Usage

```heex
<.button_group>
  <.button variant="outline">Left</.button>
  <.button variant="outline">Center</.button>
  <.button variant="outline">Right</.button>
</.button_group>
```

## Orientation

Button groups can be horizontal (default) or vertical.

```heex
<.button_group orientation="vertical">
  <.button variant="outline" size="icon">
    <.icon name="hero-plus" />
  </.button>
  <.button variant="outline" size="icon">
    <.icon name="hero-minus" />
  </.button>
</.button_group>
```

## Split Button

Create a split button by combining a button with a separator and an icon button:

```heex
<.button_group>
  <.button variant="secondary">Send</.button>
  <.button_group_separator />
  <.button variant="secondary" size="icon">
    <.icon name="hero-chevron-down" />
  </.button>
</.button_group>
```

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `orientation` | `string` | `"horizontal"` | Layout direction: `"horizontal"` or `"vertical"` |
| `class` | `string` | `""` | Additional CSS classes |
| `rest` | `global` | - | HTML attributes including `aria-label` |
