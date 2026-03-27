%{
  title: "Checkbox",
  description: "Boolean checkbox inputs with optional labels and checked states.",
  group: "Forms",
  order: 2,
  icon: "hero-document-text"
}
---

Use `checkbox` for single boolean choices such as consent, feature toggles, or filter options.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Basic Usage

Pass `label` to let PUI render the checkbox and text together.

```heex
<.checkbox id="terms" name="terms" label="I agree to the terms" />
```

## Checked State

Use the standard `checked` attribute when you want the checkbox to render selected.

```heex
<.checkbox
  id="newsletter"
  name="newsletter"
  label="Subscribe to newsletter"
  checked
/>
```

## Custom Label Layout

If you need custom copy or layout, render the label manually and place the checkbox inside it.

```heex
<label class="flex items-start gap-3">
  <.checkbox id="updates" name="updates" />
  <span class="text-sm text-foreground">
    Send me weekly product updates.
  </span>
</label>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text when using the built-in wrapper |
| `class` | `string` | `nil` | Additional CSS classes |
| `checked` | `boolean` | — | Render the checkbox as checked |
| `disabled` | `boolean` | `false` | Disable the checkbox |
| `name` | `string` | — | Form field name |
| `value` | `string` | — | Submitted value |
