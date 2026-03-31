%{
  title: "Button",
  description: "Versatile action triggers with multiple variants, sizes, and navigation support.",
  group: "Actions",
  order: 0,
  icon: "hero-cursor-arrow-rays"
}
---

The Button component provides a flexible, accessible button element with multiple visual variants and sizes. It supports navigation via Phoenix's `navigate`, `patch`, and `href` attributes.

## Import

```elixir
use PUI
# or
import PUI.Button
```

## Basic Usage

```heex
<.button>Click me</.button>
```

<AppWeb.DocsDemo.button_playground_demo btn_variant={@btn_variant} btn_size={@btn_size} />

## Variants

Buttons come in several visual styles to communicate different levels of emphasis and intent.

| Variant | Usage |
|---------|-------|
| `default` | Primary actions, main call-to-action |
| `secondary` | Less prominent actions |
| `destructive` | Dangerous or irreversible actions |
| `outline` | Bordered buttons for subtle emphasis |
| `ghost` | Minimal buttons for toolbars and inline actions |
| `link` | Styled as links for inline navigation |

```heex
<.button variant="default">Default</.button>
<.button variant="secondary">Secondary</.button>
<.button variant="destructive">Destructive</.button>
<.button variant="outline">Outline</.button>
<.button variant="ghost">Ghost</.button>
<.button variant="link">Link</.button>
```

<AppWeb.DocsDemo.button_variants_demo />

## Sizes

Control the button size using the `size` attribute.

```heex
<.button size="sm">Small</.button>
<.button size="default">Default</.button>
<.button size="lg">Large</.button>
<.button size="icon">🔔</.button>
```

<AppWeb.DocsDemo.button_sizes_demo />

## Navigation

Buttons can act as navigation links using Phoenix's built-in attributes:

```heex
<!-- Client-side navigation (LiveView) -->
<.button navigate={~p"/dashboard"}>Go to Dashboard</.button>

<!-- Patch current LiveView -->
<.button patch={~p"/settings"}>Settings</.button>

<!-- Traditional link -->
<.button href="https://example.com">External Link</.button>
```

## Disabled State

```heex
<.button disabled>Disabled</.button>
<.button variant="destructive" disabled>Can't Delete</.button>
```

<AppWeb.DocsDemo.button_disabled_demo />

## With Icons

Combine buttons with icon components for rich visual cues:

```heex
<.button>
  <.icon name="hero-plus" class="size-4 mr-2" /> Add Item
</.button>

<.button variant="destructive">
  <.icon name="hero-trash" class="size-4 mr-2" /> Delete
</.button>

<.button size="icon" variant="ghost">
  <.icon name="hero-cog-6-tooth" class="size-5" />
</.button>
```

<AppWeb.DocsDemo.button_icons_demo />

## Unstyled / Headless

Use `variant="unstyled"` to get a button with no default styles — perfect for building custom designs:

```heex
<.button variant="unstyled" class="my-custom-btn">
  Fully Custom
</.button>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | Visual style: `"default"`, `"secondary"`, `"destructive"`, `"outline"`, `"ghost"`, `"link"`, `"unstyled"` |
| `size` | `string` | `"default"` | Button size: `"default"`, `"sm"`, `"lg"`, `"icon"` |
| `class` | `string` | `""` | Additional CSS classes |
| `disabled` | `boolean` | `false` | Disables the button |
| `navigate` | `string` | — | LiveView client-side navigation path |
| `patch` | `string` | — | LiveView patch navigation path |
| `href` | `string` | — | Standard link href |

### Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Button content (text, icons, etc.) |
