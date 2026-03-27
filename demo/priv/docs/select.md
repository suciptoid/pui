%{
  title: "Select",
  description: "Customizable dropdown with search, grouping, keyboard navigation, and form integration.",
  group: "Forms",
  order: 1,
  icon: "hero-document-text"
}
---

The Select component provides a rich dropdown selection experience with built-in search, option grouping, keyboard navigation, and seamless Phoenix form integration. It supports multiple option formats including strings, tuples, and grouped options.

## Import

```elixir
use PUI
# or
import PUI.Select
```

## Basic Usage

The simplest select takes an `options` list of strings:

```heex
<.select
  id="fruit"
  name="fruit"
  label="Favorite Fruit"
  options={["Apple", "Banana", "Cherry", "Date"]}
/>
```

## Custom Items

Use `select_item` for full control over each option's rendering:

```heex
<.select id="food" name="food" label="Select Food">
  <.select_item value="pizza">
    <.icon name="hero-fire" class="size-4" /> Pizza
  </.select_item>
  <.select_item value="sushi">
    <.icon name="hero-star" class="size-4" /> Sushi
  </.select_item>
</.select>
```

## Searchable

Enable filtering by setting `searchable={true}`:

```heex
<.select
  id="country"
  name="country"
  label="Country"
  placeholder="Search countries..."
  searchable={true}
  options={["Argentina", "Brazil", "Canada", "Denmark", "Egypt"]}
/>
```

## Default Value

Pre-select an option using the `value` attribute:

```heex
<.select
  id="plan"
  name="plan"
  label="Plan"
  value="pro"
  options={[{"free", "Free"}, {"pro", "Pro"}, {"enterprise", "Enterprise"}]}
/>
```

## Option Formats

Select accepts several option formats:

### String List

```heex
<.select options={["Option A", "Option B", "Option C"]} />
```

### Tuple List (value, label)

```heex
<.select options={[{"val1", "Label One"}, {"val2", "Label Two"}]} />
```

### Grouped Options

Organize options into categories:

```heex
<.select
  id="grouped"
  name="grouped"
  searchable={true}
  options={[
    {"Fruits", ["Apple", "Banana", "Cherry"]},
    {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}]}
  ]}
/>
```

## Header and Footer Slots

Add custom content above or below the options list:

```heex
<.select id="with-footer" name="item" searchable={true}>
  <.select_item value="item-1">Item One</.select_item>
  <.select_item value="item-2">Item Two</.select_item>
  <:footer>
    <div class="border-t border-border p-2">
      <button type="button" phx-click="add-item"
        class="flex items-center gap-2 text-sm text-primary">
        <.icon name="hero-plus" class="size-4" /> Add New Item
      </button>
    </div>
  </:footer>
</.select>
```

## Form Integration

Select works seamlessly with Phoenix forms:

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.select
    field={@form[:category]}
    label="Category"
    searchable={true}
    options={["Technology", "Design", "Business"]}
  />
  <.button type="submit">Save</.button>
</.form>
```

## Unstyled / Headless

Use `variant="unstyled"` for full styling control:

```heex
<.select variant="unstyled" id="custom" name="custom" class="my-select">
  <.select_item value="a" variant="unstyled">Option A</.select_item>
</.select>
```

## API Reference

### Select Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | `nil` | Unique identifier |
| `name` | `string` | `nil` | Form field name |
| `value` | `string` | `nil` | Currently selected value |
| `placeholder` | `string` | `"Select an item"` | Placeholder text |
| `options` | `list` | `[]` | Options list (strings, tuples, or grouped) |
| `searchable` | `boolean` | `false` | Enable search/filter |
| `label` | `string` | `nil` | Label text |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `field` | `FormField` | `nil` | Phoenix form field |
| `class` | `string` | `"w-fit"` | Additional CSS classes |

### Select Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | — | Custom select items |
| `header` | — | Content above the options list |
| `footer` | — | Content below the options list |

### SelectItem Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `string` | **required** | Option value |
| `class` | `string` | `""` | Additional CSS classes |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
