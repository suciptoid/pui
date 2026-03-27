%{
  title: "Input",
  description: "Form input components including text fields, checkboxes, radio buttons, switches, and textareas.",
  group: "Forms",
  order: 0,
  icon: "hero-document-text"
}
---

PUI provides a comprehensive set of form input components that integrate seamlessly with Phoenix forms and LiveView. Each input type supports labels, error states, and form field bindings.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Text Input

The basic `input` component renders a styled text field with optional label.

```heex
<.input id="name" name="name" label="Full Name" placeholder="Enter your name" />
```

### Input Types

The `type` attribute accepts any standard HTML input type:

```heex
<.input type="text" label="Text" name="text" />
<.input type="email" label="Email" name="email" placeholder="you@example.com" />
<.input type="password" label="Password" name="password" />
<.input type="number" label="Quantity" name="qty" min="0" max="100" />
<.input type="url" label="Website" name="url" placeholder="https://" />
<.input type="tel" label="Phone" name="phone" />
<.input type="date" label="Date" name="date" />
```

## Checkbox

Renders a styled checkbox with an optional label.

```heex
<.checkbox id="terms" name="terms" label="I agree to the terms" />
<.checkbox id="newsletter" name="newsletter" label="Subscribe to newsletter" checked />
```

## Radio Button

```heex
<.radio id="plan-free" name="plan" value="free" />
<.radio id="plan-pro" name="plan" value="pro" />
<.radio id="plan-enterprise" name="plan" value="enterprise" />
```

## Switch / Toggle

A toggle switch component for boolean values:

```heex
<.switch id="notifications" name="notifications" label="Enable notifications" />
<.switch id="dark-mode" name="dark_mode" label="Dark mode" />
```

## Textarea

```heex
<.textarea id="bio" name="bio" label="Biography" placeholder="Tell us about yourself..." rows="4" />
```

## Form Integration

All input components work with Phoenix form fields via the `field` attribute:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.checkbox field={@form[:terms]} label="Accept terms" />
  <.switch field={@form[:newsletter]} label="Subscribe" />
  <.textarea field={@form[:bio]} label="Bio" />
  <.button type="submit">Save</.button>
</.form>
```

When using form fields, error messages are automatically displayed when the field has been interacted with.

## API Reference

### Input Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Input element ID |
| `type` | `string` | `"text"` | HTML input type |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field for automatic name/value/error binding |
| `class` | `string` | `""` | Additional CSS classes |
| `placeholder` | `string` | — | Placeholder text |
| `required` | `boolean` | `false` | Mark as required |
| `disabled` | `boolean` | `false` | Disable the input |

### Checkbox Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field |
| `class` | `string` | `nil` | Additional CSS classes |
| `checked` | `boolean` | — | Checked state |

### Switch Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field |
| `class` | `string` | `""` | Additional CSS classes |

### Textarea Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field |
| `class` | `string` | `""` | Additional CSS classes |
| `rows` | `string` | — | Number of visible text lines |
