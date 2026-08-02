# PUI.Table

`PUI.Table` is a styled, stream-aware data table for Phoenix LiveView. It owns table structure and presentation while the host application owns data loading, sorting, filtering, pagination, authorization, and row actions.

## Basic usage

`rows` accepts an ordinary list. Each `:col` slot receives one row, and its `label` becomes the table header:

```heex
<.table id="users" rows={@users}>
  <:col :let={user} label="Name">{user.name}</:col>
  <:col :let={user} label="Email">{user.email}</:col>
  <:action :let={user}>
    <.button size="sm" variant="ghost" phx-click="edit" phx-value-id={user.id}>
      Edit
    </.button>
  </:action>
</.table>
```

Rows with an `id` field receive that value as their DOM ID by default. For another identity scheme, provide `row_id`:

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

Pass a stream directly to `rows` to use LiveView's incremental DOM updates:

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

For a stream, slots receive `{dom_id, item}` tuples. This lets the host use the stream's identity and item together. `row_click` and `row_id` receive the same rendered row value:

```heex
<.table
  id="invoices"
  rows={@streams.invoices}
  row_click={fn {_dom_id, invoice} -> JS.push("show_invoice", value: %{id: invoice.id}) end}
>
  <:col :let={{_dom_id, invoice}} label="Invoice">{invoice.number}</:col>
  <:col :let={{_dom_id, invoice}} label="Total">{invoice.total}</:col>
</.table>
```

## Empty state

The `:empty` slot renders for an ordinary empty list. Stream emptiness is owned by the host because a stream may be incrementally updated:

```heex
<.table id="members" rows={@members}>
  <:col :let={member} label="Name">{member.name}</:col>
  <:empty>
    <div class="px-6 py-10 text-center text-sm text-muted-foreground">
      No members have been added yet.
    </div>
  </:empty>
</.table>
```

## Part-level customization

The default variant supplies a complete shadcn-inspired recipe. Customize each rendered part without replacing the table markup:

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

Column-specific `header_class` and `cell_class` values are useful for numeric alignment or status columns:

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

Use `variant="unstyled"` when the application owns every visual class but still wants PUI's table structure, row identity, stream behavior, and slot contract:

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

In unstyled mode PUI does not add visual classes. The semantic table elements, stable body ID, stream metadata, slots, and row behavior remain intact.

## Responsibility boundary

PUI.Table deliberately does not implement:

- sorting or sort indicators;
- filtering or search inputs;
- pagination or infinite loading;
- authorization decisions;
- database queries or stream lifecycle;
- row action semantics.

Compose those behaviors in the host LiveView and pass the resulting rows, callbacks, and controls into the table.

## API reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | required | Stable ID for the table body and LiveView stream target |
| `rows` | `list` or stream | required | Rows to render |
| `row_id` | function | derived | Returns a DOM ID for a rendered row |
| `row_click` | function | `nil` | Returns the `phx-click` value for data cells |
| `row_item` | function | identity | Maps a rendered row before passing it to slots |
| `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
| `action_label` | `string` | `"Actions"` | Accessible label for the action column |
| `class` | `string` | `""` | Outer overflow wrapper classes |
| `caption_class` | `string` | `"sr-only"` | Table caption classes |
| `table_class` | `string` | `""` | `<table>` classes |
| `header_class` | `string` | `""` | `<thead>` classes |
| `header_cell_class` | `string` | `""` | Default classes for header cells |
| `body_class` | `string` | `""` | `<tbody>` classes |
| `row_class` | `string` | `""` | Default classes for rows |
| `cell_class` | `string` | `""` | Default classes for data cells |
| `action_header_class` | `string` | `""` | Action header cell classes |
| `action_cell_class` | `string` | `""` | Action cell classes |
| `action_class` | `string` | `""` | Inner action wrapper classes |
| `empty_class` | `string` | `""` | Empty-state cell classes |

Global HTML and ARIA attributes are forwarded to the `<table>` element.

### Slots

| Slot | Required | Attributes | Description |
|------|----------|------------|-------------|
| `caption` | — | — | Optional accessible table caption |
| `col` | yes | `label`, `class`, `header_class`, `cell_class` | A data column rendered for every row |
| `action` | — | `class` | Row actions rendered in a final column |
| `empty` | — | — | Empty state for ordinary empty lists |
