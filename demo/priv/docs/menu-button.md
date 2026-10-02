%{
  title: "Menu Button",
  description: "Button with a dropdown menu popup for actions and navigation.",
  group: "Actions",
  order: 2,
  icon: "hero-bars-3"
}
---

The Menu Button component combines a button trigger with a dropdown menu popup. It's ideal for row actions, toolbar menus, and context menus.

## Import

```elixir
use PUI
# or
import PUI.MenuButton
```

## Basic Usage

```heex
<.menu_button>
  Actions
  <:item>Edit</:item>
  <:item>Duplicate</:item>
  <:item>Delete</:item>
</.menu_button>
```

## Icon Trigger

Use an icon-only trigger for compact row actions:

```heex
<.menu_button variant="ghost" class="h-8 w-8 px-0" aria-label="Row actions">
  <.icon name="hero-ellipsis-horizontal" class="size-4" />
  <:item>Open</:item>
  <:item>Rename</:item>
  <:item>Delete</:item>
</.menu_button>
```

## Menu Grouping

Group related items with headings:

```heex
<.menu_button>
  Settings
  <:item>Profile</:item>
  <:item>Security</:item>
  <:item>Notifications</:item>
</.menu_button>
```

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | `string` | `"default"` | Button variant: `"default"`, `"outline"`, `"ghost"`, etc. |
| `class` | `string` | `""` | Additional CSS classes |
| `rest` | `global` | - | HTML attributes including `aria-label` |

## Slots

| Slot | Description |
|------|-------------|
| `item` | Menu items (use `<:item>` for each action) |
