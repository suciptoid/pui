%{
  title: "Switch",
  description: "Toggle-style boolean inputs with a compact switch presentation.",
  group: "Forms",
  order: 4,
  icon: "hero-document-text"
}
---

Use `switch` when you want a boolean control that reads more like an on/off setting than a checklist item.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Basic Usage

Provide `label` to render the switch and label together.

```heex
<.switch
  id="notifications"
  name="notifications"
  label="Enable notifications"
/>
```

## In Settings Screens

Switches work well for preferences and feature flags.

```heex
<.switch id="security-alerts" name="security_alerts" label="Security alerts" />
<.switch id="marketing-emails" name="marketing_emails" label="Marketing emails" />
```

## Disabled State

Use `disabled` when a setting is read-only or temporarily unavailable.

```heex
<.switch
  id="beta-access"
  name="beta_access"
  label="Beta access"
  disabled
/>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field |
| `class` | `string` | `""` | Additional CSS classes |
| `disabled` | `boolean` | `false` | Disable the switch |
| `name` | `string` | — | Form field name |
| `value` | `string` | — | Submitted value |
