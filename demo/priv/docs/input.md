%{
  title: "Input",
  description: "Single-line text inputs for text, email, password, number, and other HTML input types.",
  group: "Forms",
  order: 0,
  icon: "hero-document-text"
}
---

PUI's `input` component covers single-line form fields such as text, email, password, number, date, and file inputs. Use it when you need a standard input with PUI styling, labels, and LiveView-friendly attributes.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Basic Usage

The basic `input` component renders a styled single-line field with an optional label.

```heex
<.input id="name" name="name" label="Full Name" placeholder="Enter your name" />
```

## Common Input Types

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

<AppWeb.DocsDemo.input_demo form={@form} />

## Labels and Placeholders

Pass `label` when you want PUI to render the label wrapper for you. You can also provide placeholder text and any other standard input attributes.

```heex
<.input
  id="company"
  name="company"
  label="Company"
  placeholder="Acme Inc."
/>
```

## Form Integration

Inputs work seamlessly with Phoenix form fields via the `field` attribute:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.button type="submit">Save</.button>
</.form>
```

When using form fields, error messages are automatically displayed when the field has been interacted with.

## Manual Errors

You can also render errors without a form field by passing `errors` directly:

```heex
<.input
  id="company"
  name="company"
  label="Company"
  errors={["Please enter a company name."]}
/>
```

## Related Form Controls

- [Textarea](/docs/textarea)
- [Checkbox](/docs/checkbox)
- [Radio](/docs/radio)
- [Switch](/docs/switch)
- [Select](/docs/select)

## API Reference

### Input Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Input element ID |
| `type` | `string` | `"text"` | HTML input type |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field for automatic name/value/error binding |
| `errors` | `list` | `[]` | Error messages rendered below the input |
| `class` | `string` | `""` | Additional CSS classes |
| `placeholder` | `string` | — | Placeholder text |
| `required` | `boolean` | `false` | Mark as required |
| `disabled` | `boolean` | `false` | Disable the input |
