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

---

## Button Group

The `button_group` container groups related buttons together with connected styling. Adjacent buttons merge their borders for a cohesive look.

### Import

```elixir
use PUI
# or
import PUI.ButtonGroup
```

### Basic Usage

```heex
<.button_group>
  <.button variant="outline">Button 1</.button>
  <.button variant="outline">Button 2</.button>
  <.button variant="outline">Button 3</.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_basic_demo />

### Variants

Any button variant works inside a group. Outline buttons are the most common choice since their visible borders create natural separation.

```heex
<.button_group>
  <.button variant="default">Default</.button>
  <.button variant="default">Group</.button>
</.button_group>

<.button_group>
  <.button variant="secondary">Secondary</.button>
  <.button variant="secondary">Group</.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_variants_demo />

### Sizes

Apply any size to individual buttons within a group.

```heex
<.button_group>
  <.button variant="outline" size="sm">Small</.button>
  <.button variant="outline" size="sm">Group</.button>
</.button_group>

<.button_group>
  <.button variant="outline">Default</.button>
  <.button variant="outline">Group</.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_sizes_demo />

### With Separator

Use `button_group_separator` to visually divide buttons within a group. Separators are most useful with non-outline variants since outline buttons already have visible borders.

```heex
<.button_group>
  <.button variant="secondary">Copy</.button>
  <.button_group_separator />
  <.button variant="secondary">Paste</.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_separator_demo />

### With Text

Use `button_group_text` to add a label within the group. The text element matches button height and inherits the group's connected styling.

```heex
<.button_group>
  <.button_group_text>https://</.button_group_text>
  <.button variant="outline">example.com</.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_text_demo />

### Vertical Orientation

Set `orientation="vertical"` to stack buttons vertically.

```heex
<.button_group orientation="vertical">
  <.button variant="outline" size="icon">
    <.icon name="hero-plus" class="size-4" />
  </.button>
  <.button variant="outline" size="icon">
    <.icon name="hero-minus" class="size-4" />
  </.button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_orientation_demo bg_orientation={@bg_orientation} />

### Split Button

Create a split button by combining a primary action with a `menu_button` dropdown. Use the `class` attribute on `menu_button` to forward the border-radius override to the inner button.

```heex
<.button_group>
  <.button variant="secondary">Send</.button>
  <.button_group_separator />
  <.menu_button variant="secondary" class="rounded-l-none" content_class="w-40">
    <.icon name="hero-chevron-down" class="size-4" />
    <:item>Reply All</:item>
    <:item>Forward</:item>
    <:item variant="destructive">Delete</:item>
  </.menu_button>
</.button_group>
```

<AppWeb.DocsDemo.button_group_split_demo />

### Button Group vs Toggle Group

- Use `button_group` when you want to group buttons that **perform an action**.
- Use a toggle group when you want to group buttons that **toggle a state**.

### Accessibility

- The container has `role="group"` for assistive technologies.
- Use `aria-label` or `aria-labelledby` to describe the group's purpose.
- Use `Tab` to navigate between buttons in the group.

```heex
<.button_group aria-label="Formatting options">
  <.button variant="outline">Bold</.button>
  <.button variant="outline">Italic</.button>
  <.button variant="outline">Underline</.button>
</.button_group>
```

## Button Group API Reference

### button_group

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `orientation` | `string` | `"horizontal"` | Layout direction: `"horizontal"` or `"vertical"` |
| `class` | `string` | `""` | Additional CSS classes |
| `rest` | `global` | — | HTML attributes including `aria-label` |

#### Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Group content — buttons, separators, text, or nested groups |

### button_group_separator

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `orientation` | `string` | `"horizontal"` | Separator direction: `"horizontal"` renders a vertical line, `"vertical"` renders a horizontal line |
| `class` | `string` | `""` | Additional CSS classes |

### button_group_text

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `class` | `string` | `""` | Additional CSS classes |

#### Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Text content |
