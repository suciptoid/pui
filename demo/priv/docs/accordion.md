%{
  title: "Accordion",
  description: "Expandable sections for FAQs, settings panels, and progressively disclosed content.",
  group: "Data Display",
  order: 1,
  icon: "hero-bars-4"
}
---

The Accordion component provides shadcn-inspired disclosure primitives built on native HTML elements. It is ideal for FAQs, compact settings panels, and any UI where you want to reveal details progressively without custom JavaScript.

## Import

```elixir
use PUI
# or
import PUI.Accordion
```

## Basic Usage

Use `accordion/1` as the wrapper and compose items with `accordion_item/1`, `accordion_trigger/1`, and `accordion_content/1`.

```heex
<.accordion class="max-w-xl">
  <.accordion_item name="faq" open>
    <.accordion_trigger>Is it accessible?</.accordion_trigger>
    <.accordion_content>
      Yes. It uses native details and summary elements.
    </.accordion_content>
  </.accordion_item>

  <.accordion_item name="faq">
    <.accordion_trigger>Can I style it?</.accordion_trigger>
    <.accordion_content>
      Yes. Use the default classes or switch to `variant="unstyled"`.
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

<AppWeb.DocsDemo.accordion_single_demo />

## Single Open Behavior

Set the same `name` on sibling `accordion_item/1` entries when you want the browser to keep only one panel open at a time.

```heex
<.accordion>
  <.accordion_item name="settings" open>
    <.accordion_trigger>Account</.accordion_trigger>
    <.accordion_content>Account settings…</.accordion_content>
  </.accordion_item>

  <.accordion_item name="settings">
    <.accordion_trigger>Billing</.accordion_trigger>
    <.accordion_content>Billing settings…</.accordion_content>
  </.accordion_item>
</.accordion>
```

## Multiple Open Items

Leave `name` unset to allow multiple sections to remain expanded at once.

```heex
<.accordion class="rounded-xl border border-border px-4">
  <.accordion_item open class="last:border-b-0">
    <.accordion_trigger>Notifications</.accordion_trigger>
    <.accordion_content>Notification preferences…</.accordion_content>
  </.accordion_item>

  <.accordion_item class="last:border-b-0">
    <.accordion_trigger>Privacy</.accordion_trigger>
    <.accordion_content>Privacy controls…</.accordion_content>
  </.accordion_item>
</.accordion>
```

<AppWeb.DocsDemo.accordion_multiple_demo />

## Headless / Unstyled

Use `variant="unstyled"` when you want to keep the semantic structure but take over the presentation completely.

```heex
<.accordion variant="unstyled" class="space-y-3">
  <.accordion_item variant="unstyled" class="rounded-2xl border" open>
    <.accordion_trigger
      variant="unstyled"
      class="flex w-full items-center justify-between px-4 py-3"
    >
      Custom trigger
    </.accordion_trigger>

    <.accordion_content variant="unstyled" class="px-4 pb-4 text-sm">
      Fully custom content styling.
    </.accordion_content>
  </.accordion_item>
</.accordion>
```

<AppWeb.DocsDemo.accordion_headless_demo />

## Notes on Styling

The default styles follow the same shadcn-inspired theme tokens used by the rest of PUI, including `border-border`, `text-muted-foreground`, and focus ring utilities. That keeps the accordion aligned with the active light or dark theme automatically.

Because the component is built on `<details>` and `<summary>`, it works well for:

- FAQ sections
- Settings categories
- Compact side panels
- Disclosure-heavy mobile layouts

## API Reference

### `accordion/1` Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional wrapper classes |

### `accordion_item/1` Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | `nil` | Shared group name for single-open behavior |
| `open` | `boolean` | `false` | Whether the item starts expanded |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional item classes |

### `accordion_trigger/1` Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `icon` | `boolean` | `true` | Show the chevron icon |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional trigger classes |

### `accordion_content/1` Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `class` | `string` | `""` | Additional content classes |
