%{
  title: "Container",
  description: "Structural helpers for page headers and Heroicons.",
  group: "Layout",
  order: 1,
  icon: "hero-view-columns"
}
---

`PUI.Container` provides structural helpers that do not belong to a single
content family. Cards are documented separately under [`PUI.Card`](/docs/card).

## Import

```elixir
use PUI
# or
import PUI.Container
```

## Page Header

Use `header/1` for a page-level heading with an optional subtitle and actions:

```heex
<.header>
  Dashboard
  <:subtitle>Welcome back! Here's what's happening.</:subtitle>
  <:actions>
    <.button>New report</.button>
  </:actions>
</.header>
```

## Icon

Render bundled Heroicons by name:

```heex
<.icon name="hero-check-circle" />
<.icon name="hero-arrow-path" class="size-5 animate-spin" />
```

The canonical Card module is `PUI.Card`. Existing qualified
`PUI.Container.card*` calls remain available as deprecated compatibility
wrappers.

## API Reference

### Header slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | yes | Page title |
| `subtitle` | — | Supporting description |
| `actions` | — | Right-aligned actions |

### Icon attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | required | Heroicon name beginning with `hero-` |
| `class` | `string` | `"size-4"` | Icon classes |
