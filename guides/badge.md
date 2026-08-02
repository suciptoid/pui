# PUI.Badge

`PUI.Badge` renders a compact label for statuses, categories, and counts.

## Usage

```heex
<.badge>Default</.badge>
<.badge variant="secondary">Active</.badge>
<.badge variant="destructive">Error</.badge>
<.badge variant="outline">Draft</.badge>
```

Use `class` to add application-specific presentation without replacing the
default recipe:

```heex
<.badge variant="secondary" class="uppercase tracking-wide">Review</.badge>
```

## Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | `"default"`, `"secondary"`, `"destructive"`, or `"outline"` |
| `class` | `string` | `""` | Additional CSS classes |

## Slots

| Slot | Required | Description |
|------|----------|-------------|
| `inner_block` | yes | Badge content |

The canonical module is `PUI.Badge`. Existing `PUI.Components.badge/1` calls
remain available as deprecated compatibility wrappers.
