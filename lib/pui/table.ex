defmodule PUI.Table do
  @moduledoc """
  A styled, stream-aware data table for Phoenix LiveView.

  `PUI.Table` renders the structure and presentation of a data table while the
  host application owns data loading, sorting, filtering, pagination, and row
  actions. It supports ordinary lists and LiveView stream collections through
  the same column and action slots.

  ## Basic usage

      <.table id="users" rows={@users}>
        <:col :let={user} label="Name">{user.name}</:col>
        <:col :let={user} label="Email">{user.email}</:col>
        <:action :let={user}>
          <.button size="sm" variant="ghost" phx-click="edit" phx-value-id={user.id}>
            Edit
          </.button>
        </:action>
      </.table>

  ## LiveView streams

  Pass a stream directly to `rows`. The stream item given to the slots is a
  `{dom_id, item}` tuple, matching Phoenix's stream rendering contract. The
  default row ID uses the stream DOM ID; provide `row_id` when the host needs a
  different identity function.

      <.table id="projects" rows={@streams.projects}>
        <:col :let={{_dom_id, project}} label="Project">{project.name}</:col>
        <:col :let={{_dom_id, project}} label="Status">{project.status}</:col>
      </.table>

  ## Customization

  Styled tables use PUI's semantic token classes by default. The component
  exposes separate class attributes for each rendered part, so an application
  can customize the table without replacing its structure. Use
  `variant="unstyled"` when the application wants to provide all visual
  classes itself.

      <.table
        id="invoices"
        rows={@invoices}
        variant="unstyled"
        class="overflow-hidden rounded-xl border"
        table_class="w-full text-sm"
        header_class="bg-muted"
        row_class="border-b last:border-b-0"
        cell_class="px-4 py-3"
      >
        <:col :let={invoice} label="Number">{invoice.number}</:col>
        <:col :let={invoice} label="Total" cell_class="text-right">{invoice.total}</:col>
      </.table>

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | required | Stable ID for the table body and LiveView stream target |
  | `rows` | `list` or LiveView stream | required | A list of rows or a LiveView stream |
  | `row_id` | `function` | derived | Function receiving a rendered row and returning its DOM ID |
  | `row_click` | `function` | `nil` | Function receiving a rendered row and returning a `phx-click` value |
  | `row_item` | `function` | identity | Function mapping a rendered row before it is passed to slots |
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `action_label` | `string` | `"Actions"` | Screen-reader label for the action column |
  | `class` | `string` | `""` | Classes for the outer overflow wrapper |
  | `caption_class` | `string` | `"sr-only"` | Classes for the table caption |
  | `table_class` | `string` | `""` | Classes for the `<table>` element |
  | `header_class` | `string` | `""` | Classes for the `<thead>` element |
  | `header_cell_class` | `string` | `""` | Classes for each column header cell |
  | `body_class` | `string` | `""` | Classes for the `<tbody>` element |
  | `row_class` | `string` | `""` | Classes for each row |
  | `cell_class` | `string` | `""` | Classes for each data cell |
  | `action_header_class` | `string` | `""` | Classes for the action header cell |
  | `action_cell_class` | `string` | `""` | Classes for the action data cell |
  | `action_class` | `string` | `""` | Classes for the action cell's inner wrapper |
  | `empty_class` | `string` | `""` | Classes for the empty-state cell |

  ## Slots

  | Slot | Required | Description |
  |------|----------|-------------|
  | `caption` | — | Optional table caption |
  | `col` | yes | A data column; supports `label`, `class`, `header_class`, and `cell_class` |
  | `action` | — | Optional row actions; receives the rendered row |
  | `empty` | — | Empty-state content for ordinary empty lists |
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :rows, :any, required: true
  attr :row_id, :any, default: nil
  attr :row_click, :any, default: nil
  attr :row_item, :any, default: &Function.identity/1
  attr :variant, :string, values: ["default", "unstyled"], default: "default"
  attr :action_label, :string, default: "Actions"
  attr :class, :string, default: ""
  attr :caption_class, :string, default: "sr-only"
  attr :table_class, :string, default: ""
  attr :header_class, :string, default: ""
  attr :header_cell_class, :string, default: ""
  attr :body_class, :string, default: ""
  attr :row_class, :string, default: ""
  attr :cell_class, :string, default: ""
  attr :action_header_class, :string, default: ""
  attr :action_cell_class, :string, default: ""
  attr :action_class, :string, default: ""
  attr :empty_class, :string, default: ""
  attr :rest, :global

  slot :caption

  slot :col, required: true do
    attr :label, :string
    attr :class, :string
    attr :header_class, :string
    attr :cell_class, :string
  end

  slot :action do
    attr :class, :string
  end

  slot :empty

  @doc """
  Renders a data table from a list or LiveView stream.

  The `:col` slot receives the row produced by `row_item/1`. With ordinary
  lists this is the original row. With LiveView streams it is a `{dom_id, item}`
  tuple unless `row_item` maps it to another value.
  """
  def table(%{variant: variant} = assigns) do
    is_stream = match?(%Phoenix.LiveView.LiveStream{}, assigns.rows)
    row_id = assigns.row_id || (&default_row_id/1)

    assigns =
      assigns
      |> assign(:is_stream, is_stream)
      |> assign(:row_id, row_id)
      |> assign(:classes, classes(variant))

    ~H"""
    <div data-pui="table" class={[@classes.wrapper, @class]}>
      <table class={[@classes.table, @table_class]} {@rest}>
        <caption :if={@caption != []} class={@caption_class}>
          {render_slot(@caption)}
        </caption>
        <thead class={[@classes.header, @header_class]}>
          <tr>
            <th
              :for={col <- @col}
              class={[
                @classes.header_cell,
                @header_cell_class,
                col[:class],
                col[:header_class]
              ]}
            >
              {col[:label]}
            </th>
            <th :if={@action != []} class={[@classes.action_header, @action_header_class]}>
              <span class="sr-only">{@action_label}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={if @is_stream, do: "stream"}
          class={[@classes.body, @body_class]}
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class={[@classes.row, @row_class]}
          >
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={[
                @classes.cell,
                @cell_class,
                col[:class],
                col[:cell_class],
                @row_click && "cursor-pointer"
              ]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class={[@classes.action_cell, @action_cell_class]}>
              <div class={[@classes.action, @action_class]}>
                <%= for action <- @action do %>
                  <div class={action[:class]}>{render_slot(action, @row_item.(row))}</div>
                <% end %>
              </div>
            </td>
          </tr>
          <tr :if={!@is_stream and @rows == [] and @empty != []}>
            <td
              colspan={length(@col) + if(@action != [], do: 1, else: 0)}
              class={@empty_class}
            >
              {render_slot(@empty)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp default_row_id({dom_id, _item}), do: normalize_dom_id(dom_id)
  defp default_row_id(%{id: id}), do: normalize_dom_id(id)
  defp default_row_id(_row), do: nil

  defp normalize_dom_id(nil), do: nil
  defp normalize_dom_id(id), do: to_string(id)

  defp classes("unstyled") do
    %{
      wrapper: "",
      table: "",
      header: "",
      header_cell: "",
      body: "",
      row: "",
      cell: "",
      action_header: "",
      action_cell: "",
      action: ""
    }
  end

  defp classes("default") do
    %{
      wrapper: "overflow-x-auto rounded-2xl border border-border bg-card shadow-xs",
      table: "w-full min-w-[28rem] text-left text-sm",
      header: "border-b border-border bg-muted/25",
      header_cell:
        "px-6 py-3 text-xs font-medium tracking-[0.12em] text-muted-foreground uppercase",
      body: "",
      row: "border-t border-border transition first:border-t-0 hover:bg-muted/30",
      cell: "px-6 py-4 align-top",
      action_header:
        "px-6 py-3 text-right text-xs font-medium tracking-[0.12em] text-muted-foreground uppercase",
      action_cell: "w-0 px-6 py-4 align-top",
      action: "flex items-center justify-end gap-2"
    }
  end
end
