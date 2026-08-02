%{
  title: "Table",
  description: "A styled, stream-aware data table with explicit customization points for Phoenix LiveView.",
  group: "Data Display",
  order: 1,
  icon: "hero-table-cells"
}
---

`PUI.Table` provides the structure and presentation for collection views while the host LiveView owns data loading, sorting, filtering, pagination, authorization, and row actions.

## Import

```elixir
use PUI
# or
import PUI.Table
```

## Basic table

Use the `:col` slot for labeled columns and the optional `:action` slot for row actions:

```heex
<.table id="projects" rows={@projects}>
  <:col :let={project} label="Project">{project.name}</:col>
  <:col :let={project} label="Status">{project.status}</:col>
  <:action :let={project}>
    <.button size="sm" variant="ghost" phx-click="open" phx-value-id={project.id}>
      Open
    </.button>
  </:action>
</.table>
```

<AppWeb.DocsDemo.table_demo />

Rows with an `id` field receive that value as their DOM ID. Supply `row_id` when the host uses a different identity:

```heex
<.table
  id="deployments"
  rows={@deployments}
  row_id={fn deployment -> "deployment-#{deployment.external_id}" end}
>
  <:col :let={deployment} label="Environment">{deployment.environment}</:col>
  <:col :let={deployment} label="Status">{deployment.status}</:col>
</.table>
```

## LiveView streams

Tables accept `@streams` directly. Stream rows are passed to slots as `{dom_id, item}` tuples, and the table marks its body with `phx-update="stream"`:

```heex
<.table id="projects" rows={@streams.projects}>
  <:col :let={{_dom_id, project}} label="Project">{project.name}</:col>
  <:col :let={{_dom_id, project}} label="Status">{project.status}</:col>
  <:action :let={{_dom_id, project}}>
    <.button size="icon" variant="ghost" phx-click="delete" phx-value-id={project.id}>
      <.icon name="hero-trash" class="size-4" />
    </.button>
  </:action>
</.table>
```

The table does not call `Enum` on a stream before rendering it. Keep stream operations in the LiveView and use `row_item` only when the slot needs a different shape:

```heex
<.table
  id="events"
  rows={@streams.events}
  row_item={fn {_dom_id, event} -> event end}
>
  <:col :let={event} label="Event">{event.name}</:col>
</.table>
```

## Row interactions

`row_click` receives the same rendered row value as `row_id`. It may return a LiveView JS command or another valid `phx-click` value:

```heex
<.table
  id="invoices"
  rows={@invoices}
  row_click={fn invoice -> JS.push("show_invoice", value: %{id: invoice.id}) end}
>
  <:col :let={invoice} label="Invoice">{invoice.number}</:col>
  <:col :let={invoice} label="Total">{invoice.total}</:col>
</.table>
```

Only data cells receive the row click. Action cells remain independent so an edit or delete button does not accidentally trigger the row action.

## Empty state

The `:empty` slot renders when an ordinary list is empty:

```heex
<.table id="members" rows={@members}>
  <:col :let={member} label="Name">{member.name}</:col>
  <:empty>
    <div class="px-6 py-10 text-center text-sm text-muted-foreground">
      No members found.
    </div>
  </:empty>
</.table>
```

For streams, the host should render an empty state outside the table when its domain state knows that no records are available. A stream is intentionally not consumed early just to infer emptiness.

## Part-level customization

The default variant supplies PUI's semantic shadcn-inspired recipe. Each major part has its own class attribute:

```heex
<.table
  id="orders"
  rows={@orders}
  class="rounded-xl border"
  table_class="min-w-full"
  header_class="bg-primary text-primary-foreground"
  header_cell_class="px-4 py-3"
  row_class="border-b last:border-b-0 hover:bg-accent/50"
  cell_class="px-4 py-3"
  action_cell_class="px-4 py-3"
>
  <:col :let={order} label="Order">{order.number}</:col>
  <:col :let={order} label="Customer">{order.customer_name}</:col>
  <:action :let={order}>
    <.button size="sm" variant="outline" phx-click="open" phx-value-id={order.id}>
      Open
    </.button>
  </:action>
</.table>
```

Columns can override the defaults independently:

```heex
<.table id="balances" rows={@balances}>
  <:col :let={account} label="Account">{account.name}</:col>
  <:col
    :let={account}
    label="Balance"
    header_class="text-right"
    cell_class="text-right tabular-nums"
  >
    {account.balance}
  </:col>
</.table>
```

## Unstyled mode

Use `variant="unstyled"` when the host design system owns every visual class:

```heex
<.table
  id="custom-table"
  rows={@rows}
  variant="unstyled"
  class="overflow-hidden rounded-xl border"
  table_class="w-full text-sm"
  header_class="bg-slate-900 text-white"
  header_cell_class="px-4 py-3 text-left"
  row_class="border-b border-slate-200"
  cell_class="px-4 py-3"
>
  <:col :let={row} label="Name">{row.name}</:col>
</.table>
```

Unstyled mode preserves table semantics, stream metadata, stable IDs, slots, and callbacks while removing PUI's visual defaults.

## Responsibility boundary

PUI.Table deliberately does not implement sorting, filtering, pagination, database queries, authorization, or stream lifecycle. Those concerns stay in the host LiveView so the same table can render a small list, a paginated query, or a LiveView stream without taking ownership of application behavior.

## API reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | required | Stable ID for the table body and stream target |
| `rows` | `list` or stream | required | Rows to render |
| `row_id` | function | derived | Returns the DOM ID for a rendered row |
| `row_click` | function | `nil` | Returns the `phx-click` value for data cells |
| `row_item` | function | identity | Maps rows before passing them to slots |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `action_label` | `string` | `"Actions"` | Accessible label for the action column |
| `class` | `string` | `""` | Outer overflow wrapper classes |
| `caption_class` | `string` | `"sr-only"` | Table caption classes |
| `table_class` | `string` | `""` | `<table>` classes |
| `header_class` | `string` | `""` | `<thead>` classes |
| `header_cell_class` | `string` | `""` | Default header cell classes |
| `body_class` | `string` | `""` | `<tbody>` classes |
| `row_class` | `string` | `""` | Default row classes |
| `cell_class` | `string` | `""` | Default data cell classes |
| `action_header_class` | `string` | `""` | Action header cell classes |
| `action_cell_class` | `string` | `""` | Action data cell classes |
| `action_class` | `string` | `""` | Inner action wrapper classes |
| `empty_class` | `string` | `""` | Empty-state cell classes |

### Slots

| Slot | Required | Attributes | Description |
|------|----------|------------|-------------|
| `caption` | — | — | Optional table caption |
| `col` | yes | `label`, `class`, `header_class`, `cell_class` | A data column |
| `action` | — | `class` | Row actions in the final column |
| `empty` | — | — | Empty state for ordinary lists |
