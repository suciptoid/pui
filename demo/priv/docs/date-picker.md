%{
  title: "Date Picker",
  description: "Calendar picker with single-date, range, bounded selection, footer slots, and native month/year selects.",
  group: "Forms",
  order: 6,
  icon: "hero-document-text"
}
---

The Date Picker components provide single-date and range selection with a server-rendered calendar, native browser month/year selects, optional bounds, and a footer slot for extra controls such as time inputs or secondary actions.

## Import

```elixir
use PUI
# or
import PUI.DatePicker
```

## Basic Usage

The single-date picker renders a trigger button, a hidden form input, and a calendar popover. Month and year dropdowns are enabled by default.

```heex
<.date_picker
  id="published-on"
  name="published_on"
  label="Publish date"
  default_month={~D[2026-04-01]}
/>
```

<AppWeb.DocsDemo.date_picker_basic_demo />

## Range Picker

Use `range_picker/1` when the user needs a start and end date. The popover stays open until both dates are selected.

```heex
<.range_picker
  id="trip-range"
  from_name="trip_start"
  to_name="trip_end"
  label="Trip dates"
  default_month={~D[2026-04-01]}
/>
```

<AppWeb.DocsDemo.date_picker_range_demo />

## Min and Max Dates

Use `min` and `max` to limit which days can be picked. Days outside the allowed range render in a muted disabled state and cannot be selected.

```heex
<.date_picker
  id="delivery-date"
  name="delivery_date"
  label="Delivery date"
  default_month={~D[2026-04-01]}
  min={~D[2026-04-10]}
  max={~D[2026-04-22]}
/>
```

<AppWeb.DocsDemo.date_picker_bounds_demo />

## Footer Slot

Add supporting UI under the calendar with the `footer` slot. This works well for time pickers, quick actions, or helper text.

```heex
<.date_picker
  id="reminder-at"
  name="reminder_at"
  label="Reminder"
>
  <:footer>
    <div class="flex items-center gap-2">
      <input
        type="time"
        class="border-input h-9 rounded-md border bg-transparent px-3 text-sm"
      />
      <.button type="button" variant="outline" size="sm">Save time</.button>
    </div>
  </:footer>
</.date_picker>
```

<AppWeb.DocsDemo.date_picker_footer_demo />

## Compact Header

Set `selectable_month={false}` to switch back to the compact button header with month labels and arrow navigation only.

```heex
<.date_picker
  id="compact-picker"
  name="compact_picker"
  label="Compact header"
  selectable_month={false}
/>
```

<AppWeb.DocsDemo.date_picker_compact_demo />

## API Reference

### Date Picker Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique identifier |
| `name` | `string` | `nil` | Form field name |
| `value` | `Date.t() \| String.t()` | `nil` | Selected date |
| `default_month` | `Date.t() \| String.t()` | `nil` | Initial month when no value is selected |
| `min` | `Date.t() \| String.t()` | `nil` | Minimum selectable date |
| `max` | `Date.t() \| String.t()` | `nil` | Maximum selectable date |
| `selectable_month` | `boolean` | `true` | Enables native month and year dropdowns |
| `placeholder` | `string` | `"Pick a date"` | Trigger placeholder |
| `label` | `string` | `nil` | Field label |
| `field` | `Phoenix.HTML.FormField` | `nil` | Phoenix form field |
| `errors` | `list` | `[]` | Error messages shown below the picker |
| `show_errors` | `boolean` | `true` | Controls error rendering |
| `class` | `string` | `"w-full"` | Additional trigger classes |
| `content_class` | `string` | `""` | Additional popup classes |

### Range Picker Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique identifier |
| `from_name` | `string` | `nil` | Start input name |
| `to_name` | `string` | `nil` | End input name |
| `from_value` | `Date.t() \| String.t()` | `nil` | Selected start date |
| `to_value` | `Date.t() \| String.t()` | `nil` | Selected end date |
| `default_month` | `Date.t() \| String.t()` | `nil` | Initial visible month |
| `number_of_months` | `integer` | `2` | Number of visible calendar months |
| `min` | `Date.t() \| String.t()` | `nil` | Minimum selectable date |
| `max` | `Date.t() \| String.t()` | `nil` | Maximum selectable date |
| `selectable_month` | `boolean` | `true` | Enables native month and year dropdowns |
| `placeholder` | `string` | `"Pick a date range"` | Trigger placeholder |
| `label` | `string` | `nil` | Field label |
| `from_field` | `Phoenix.HTML.FormField` | `nil` | Phoenix form field for the start value |
| `to_field` | `Phoenix.HTML.FormField` | `nil` | Phoenix form field for the end value |
| `errors` | `list` | `[]` | Error messages shown below the picker |
| `show_errors` | `boolean` | `true` | Controls error rendering |
| `class` | `string` | `"w-full"` | Additional trigger classes |
| `content_class` | `string` | `""` | Additional popup classes |

### Slots

| Name | Required | Description |
|------|----------|-------------|
| `footer` | — | Optional content rendered below the calendar grid |
