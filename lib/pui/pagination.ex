defmodule PUI.Pagination do
  @moduledoc """
  Accessible, host-controlled pagination links.

  Pagination renders navigation markup and page links. It does not load data,
  change LiveView assigns, or decide how URLs are built. Pass a one-argument
  `page_url` function and choose whether links use `href`, `navigate`, or
  `patch`.

  ## Example

      <.pagination
        current_page={@page}
        total_pages={@total_pages}
        page_url={fn page -> ~p"/projects?page=\#{page}" end}
        link_mode="patch"
      />

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `current_page` | `integer` | required | Current one-based page |
  | `total_pages` | `integer` | required | Total one-based page count |
  | `page_url` | `function` | required | Function receiving a page number |
  | `link_mode` | `string` | `"patch"` | `"href"`, `"navigate"`, or `"patch"` |
  | `window` | `integer` | `2` | Pages shown around the current page |
  | `aria_label` | `string` | `"Pagination"` | Navigation landmark label |
  | `class` | `string` | `""` | Additional CSS classes |
  | `rest` | `global` | — | Global HTML attributes |

  ## Slots

  `previous`, `next`, and `page` are optional slots. The `page` slot receives
  the page number through `:let` and can replace the default numeric label.
  """

  use Phoenix.Component

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :page_url, :any, required: true
  attr :link_mode, :string, values: ["href", "navigate", "patch"], default: "patch"
  attr :window, :integer, default: 2
  attr :aria_label, :string, default: "Pagination"
  attr :class, :string, default: ""
  attr :rest, :global

  slot :previous
  slot :next
  slot :page

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:items, page_items(assigns.current_page, assigns.total_pages, assigns.window))
      |> assign(:previous_page, max(assigns.current_page - 1, 1))
      |> assign(:next_page, min(assigns.current_page + 1, max(assigns.total_pages, 1)))
      |> assign(:previous_disabled?, assigns.current_page <= 1)
      |> assign(:next_disabled?, assigns.current_page >= assigns.total_pages)
      |> assign(:link_attrs, fn page -> link_attrs(assigns.link_mode, assigns.page_url.(page)) end)

    ~H"""
    <nav aria-label={@aria_label} class={["not-prose", @class]} {@rest}>
      <ul class="m-0 flex list-none items-center justify-center gap-1 p-0">
        <li>
          <%= if @previous_disabled? do %>
            <span aria-disabled="true" class={disabled_link_class()}>
              <PUI.Icon.icon name={:chevron_left} />
              <span class="sr-only">Previous page</span>
            </span>
          <% else %>
            <.link class={navigation_link_class()} {@link_attrs.(@previous_page)}>
              <%= if @previous == [] do %>
                <PUI.Icon.icon name={:chevron_left} />
                <span class="sr-only">Previous page</span>
              <% else %>
                {render_slot(@previous)}
              <% end %>
            </.link>
          <% end %>
        </li>

        <%= for item <- @items do %>
          <li>
            <%= if item == :ellipsis do %>
              <span aria-hidden="true" class="flex size-9 items-center justify-center">…</span>
              <span class="sr-only">More pages</span>
            <% else %>
              <.link
                class={page_link_class(item == @current_page)}
                aria-current={if item == @current_page, do: "page"}
                {@link_attrs.(item)}
              >
                <%= if @page == [] do %>
                  {item}
                <% else %>
                  {render_slot(@page, item)}
                <% end %>
              </.link>
            <% end %>
          </li>
        <% end %>

        <li>
          <%= if @next_disabled? do %>
            <span aria-disabled="true" class={disabled_link_class()}>
              <PUI.Icon.icon name={:chevron_right} />
              <span class="sr-only">Next page</span>
            </span>
          <% else %>
            <.link class={navigation_link_class()} {@link_attrs.(@next_page)}>
              <%= if @next == [] do %>
                <span class="sr-only">Next page</span>
                <PUI.Icon.icon name={:chevron_right} />
              <% else %>
                {render_slot(@next)}
              <% end %>
            </.link>
          <% end %>
        </li>
      </ul>
    </nav>
    """
  end

  defp page_items(current_page, total_pages, window) when total_pages > 0 do
    current_page = min(max(current_page, 1), total_pages)
    window = max(window, 1)

    pages =
      1..total_pages
      |> Enum.filter(fn page ->
        page == 1 or page == total_pages or abs(page - current_page) <= window
      end)

    {items, _previous} =
      Enum.reduce(pages, {[], nil}, fn page, {items, previous} ->
        items = if previous && page - previous > 1, do: items ++ [:ellipsis], else: items
        {items ++ [page], page}
      end)

    items
  end

  defp page_items(_current_page, _total_pages, _window), do: []

  defp link_attrs("href", url), do: %{href: url}
  defp link_attrs("navigate", url), do: %{navigate: url}
  defp link_attrs("patch", url), do: %{patch: url}

  defp navigation_link_class do
    "no-underline inline-flex h-9 min-w-9 whitespace-nowrap items-center justify-center rounded-md border border-transparent px-2 text-sm transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end

  defp disabled_link_class do
    "text-muted-foreground pointer-events-none no-underline inline-flex h-9 min-w-9 whitespace-nowrap items-center justify-center rounded-md px-2 text-sm opacity-50"
  end

  defp page_link_class(true) do
    "bg-primary text-primary-foreground hover:bg-primary/90 no-underline inline-flex h-9 min-w-9 whitespace-nowrap items-center justify-center rounded-md px-2 text-sm font-medium focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end

  defp page_link_class(false) do
    "hover:bg-accent hover:text-accent-foreground no-underline inline-flex h-9 min-w-9 whitespace-nowrap items-center justify-center rounded-md px-2 text-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
  end
end
