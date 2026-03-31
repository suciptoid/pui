%{
  title: "Radio",
  description: "Single-select radio inputs for grouped choices inside forms.",
  group: "Forms",
  order: 3,
  icon: "hero-document-text"
}
---

Use `radio` when users should choose exactly one option from a small set.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Basic Usage

Give each option the same `name` and a different `value`.

```heex
<label class="flex items-center gap-3">
  <.radio id="plan-free" name="plan" value="free" />
  <span>Free</span>
</label>

<label class="flex items-center gap-3">
  <.radio id="plan-pro" name="plan" value="pro" />
  <span>Pro</span>
</label>
```

<AppWeb.DocsDemo.radio_group_demo />

## Default Selection

Use `checked` on the option that should start selected.

```heex
<label class="flex items-center gap-3">
  <.radio id="interval-monthly" name="interval" value="monthly" checked />
  <span>Monthly billing</span>
</label>
```

## Grouping Radios

Wrap related options in a `fieldset` when the set needs a shared label or description.

```heex
<fieldset class="space-y-3">
  <legend class="text-sm font-medium text-foreground">Choose a plan</legend>

  <label class="flex items-center gap-3">
    <.radio id="starter" name="plan" value="starter" checked />
    <span>Starter</span>
  </label>

  <label class="flex items-center gap-3">
    <.radio id="enterprise" name="plan" value="enterprise" />
    <span>Enterprise</span>
  </label>
</fieldset>
```

## Errors

Radio inputs do not render validation errors inline because error placement for
radio groups varies depending on layout. Instead, surface group-level errors
outside the individual radio controls — for example below a `fieldset` or as a
separate paragraph beneath the options.

```heex
<fieldset class="space-y-3">
  <legend class="text-sm font-medium text-foreground">Choose a plan</legend>

  <label class="flex items-center gap-3">
    <.radio id="starter" name="plan" value="starter" checked />
    <span>Starter</span>
  </label>

  <p class="text-destructive text-sm mt-1">Please choose a plan.</p>
</fieldset>
```

<AppWeb.DocsDemo.radio_errors_demo />

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `class` | `string` | `""` | Additional CSS classes |
| `field` | `FormField` | `nil` | Phoenix form field |
| `checked` | `boolean` | — | Render the radio as selected |
| `disabled` | `boolean` | `false` | Disable the radio |
| `name` | `string` | — | Shared group name |
| `value` | `string` | — | Submitted value for the option |
