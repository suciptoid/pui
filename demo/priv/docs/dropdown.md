%{
  title: "Dropdown",
  description: "Menu dropdowns with items, shortcuts, separators, and destructive actions.",
  group: "Actions",
  order: 1,
  icon: "hero-cursor-arrow-rays"
}
---

The Dropdown component provides a trigger button with a floating menu of actions. Built on top of PUI's Popover, it supports keyboard navigation, shortcuts display, separators, and destructive action variants.

## Import

```elixir
use PUI
# or
import PUI.Dropdown
```

## Basic Usage

The simplest dropdown uses the `item` slot:

```heex
<.menu_button>
  Actions
  <:item>Edit</:item>
  <:item>Duplicate</:item>
  <:item>Delete</:item>
</.menu_button>
```

<AppWeb.DocsDemo.dropdown_basic_demo />

## With Shortcuts

Display keyboard shortcuts alongside menu items:

```heex
<.menu_button>
  File
  <:item shortcut="⌘N">New File</:item>
  <:item shortcut="⌘O">Open</:item>
  <:item shortcut="⌘S">Save</:item>
</.menu_button>
```

<AppWeb.DocsDemo.dropdown_shortcuts_demo />

## Destructive Items

Mark dangerous actions with the destructive variant:

```heex
<.menu_button>
  Manage
  <:item>Settings</:item>
  <:item>Export</:item>
  <:item variant="destructive" phx-click="delete">Delete</:item>
</.menu_button>
```

<AppWeb.DocsDemo.dropdown_destructive_demo />

## Button Variants

The trigger button supports all button variants:

```heex
<.menu_button variant="outline">Options</.menu_button>
<.menu_button variant="ghost">More</.menu_button>
<.menu_button variant="destructive">Danger</.menu_button>
```

<AppWeb.DocsDemo.dropdown_variants_demo />

## With Navigation

Items can navigate using Phoenix's `navigate`, `patch`, or `href`:

```heex
<.menu_button>
  Go To
  <:item navigate={~p"/dashboard"}>Dashboard</:item>
  <:item navigate={~p"/settings"}>Settings</:item>
  <:item href="https://docs.example.com">Documentation</:item>
</.menu_button>
```

## Custom Content

Use `menu_content`, `menu_item`, and `menu_separator` for full control:

```heex
<.menu_button>
  Options
  <:items>
    <.menu_item>
      <.icon name="hero-pencil" class="size-4 mr-2" /> Edit
    </.menu_item>
    <.menu_item>
      <.icon name="hero-document-duplicate" class="size-4 mr-2" /> Duplicate
    </.menu_item>
    <.menu_separator />
    <.menu_item variant="destructive">
      <.icon name="hero-trash" class="size-4 mr-2" /> Delete
    </.menu_item>
  </:items>
</.menu_button>
```

## API Reference

### MenuButton Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"secondary"` | Trigger button variant: `"default"`, `"secondary"`, `"outline"`, `"ghost"`, `"destructive"`, `"unstyled"` |
| `class` | `string` | `""` | Additional CSS classes for trigger |
| `content_class` | `string` | `""` | Additional CSS classes for dropdown content |

### MenuButton Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Trigger button text |
| `item` | — | Quick menu items (supports `variant`, `shortcut`, `href`, `navigate`, `patch`, `phx-click`) |
| `items` | — | Full custom content using `menu_item` components |

### MenuItem Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | `"default"` or `"destructive"` |
| `shortcut` | `string` | `nil` | Keyboard shortcut display text |
| `class` | `string` | `""` | Additional CSS classes |
| `is_unstyled` | `boolean` | `false` | Remove default styles |
