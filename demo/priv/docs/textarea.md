%{
  title: "Textarea",
  description: "Multi-line text fields with labels, placeholders, and Phoenix form integration.",
  group: "Forms",
  order: 1,
  icon: "hero-document-text"
}
---

Use `textarea` when you need a multi-line text field with the same visual language as the rest of PUI's form controls.

## Import

```elixir
use PUI
# or
import PUI.Input
```

## Basic Usage

```heex
<.textarea
  id="bio"
  name="bio"
  label="Biography"
  placeholder="Tell us about yourself..."
  rows="4"
/>
```

## Adjusting Height

Use the standard `rows` attribute to control the visible height.

```heex
<.textarea id="summary" name="summary" label="Summary" rows="3" />
<.textarea id="feedback" name="feedback" label="Feedback" rows="6" />
```

## Form Integration

`textarea` supports Phoenix form fields via the `field` attribute:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.textarea field={@form[:notes]} label="Notes" rows="5" />
  <.button type="submit">Save</.button>
</.form>
```

Validation errors appear automatically for used form fields, or you can provide
them manually:

```heex
<.textarea
  id="notes"
  name="notes"
  label="Notes"
  errors={["Please add a short note."]}
/>
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `any` | `nil` | Element ID |
| `label` | `string` | `nil` | Label text |
| `field` | `FormField` | `nil` | Phoenix form field |
| `errors` | `list` | `[]` | Error messages rendered below the textarea |
| `class` | `string` | `""` | Additional CSS classes |
| `rows` | `string` | — | Number of visible text lines |
| `placeholder` | `string` | — | Placeholder text |
| `disabled` | `boolean` | `false` | Disable the textarea |
