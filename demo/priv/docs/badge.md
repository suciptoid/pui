%{
  title: "Badge",
  description: "Compact labels for statuses, categories, and counts.",
  group: "Data Display",
  order: 0,
  icon: "hero-tag"
}
---

`PUI.Badge` renders compact labels for statuses, categories, and counts.

## Import

```elixir
use PUI
# or
import PUI.Badge
```

## Variants

```heex
<.badge>Default</.badge>
<.badge variant="secondary">Active</.badge>
<.badge variant="destructive">Error</.badge>
<.badge variant="outline">Draft</.badge>
```

<AppWeb.DocsDemo.badge_demo />

## API Reference

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | `"default"`, `"secondary"`, `"destructive"`, or `"outline"` |
| `class` | `string` | `""` | Additional CSS classes |

| Slot | Required | Description |
|------|----------|-------------|
| `inner_block` | yes | Badge content |
