%{
  title: "Alert",
  description: "Alert components for displaying important messages and status updates.",
  group: "Feedback",
  order: 0,
  icon: "hero-speaker-wave"
}
---

The Alert component displays important messages and status updates with optional icon, title, and description slots. It supports default and destructive variants for different severity levels.

## Import

```elixir
use PUI
# or
import PUI.Alert
```

## Basic Usage

```heex
<.alert>
  <:title>Heads up!</:title>
  <:description>You can add components to your app using the CLI.</:description>
</.alert>
```

<AppWeb.DocsDemo.alert_demo />

## With Icon

Add an icon to draw attention:

```heex
<.alert>
  <:icon>
    <.icon name="hero-information-circle" class="size-5" />
  </:icon>
  <:title>Information</:title>
  <:description>This is an informational alert message.</:description>
</.alert>
```

## Destructive Variant

Use the destructive variant for error or warning messages:

```heex
<.alert variant="destructive">
  <:icon>
    <.icon name="hero-exclamation-triangle" class="size-5" />
  </:icon>
  <:title>Error</:title>
  <:description>Something went wrong. Please try again.</:description>
</.alert>
```

## Custom Content

Use `inner_block` for fully custom alert content:

```heex
<.alert>
  <div class="flex items-center gap-3">
    <.icon name="hero-check-circle" class="size-5 text-green-500" />
    <div>
      <p class="font-semibold">Success!</p>
      <p class="text-sm">Your changes have been saved.</p>
    </div>
  </div>
</.alert>
```

## Unstyled / Headless

```heex
<.alert variant="unstyled" class="my-custom-alert">
  <:title>Custom Alert</:title>
  <:description>With your own styles.</:description>
</.alert>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | Visual style: `"default"`, `"destructive"`, `"unstyled"` |
| `class` | `string` | `""` | Additional CSS classes |
| `role` | `string` | `nil` | ARIA role attribute |

### Slots

| Name | Required | Description |
|------|----------|-------------|
| `icon` | — | Icon element displayed at the start |
| `title` | — | Alert title (supports `class`) |
| `description` | — | Alert description text (supports `class`) |
| `inner_block` | — | Custom content (alternative to named slots) |
