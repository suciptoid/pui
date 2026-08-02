# PUI.Pagination

`PUI.Pagination` renders accessible pagination links without owning data
loading, query parameters, or LiveView state.

## Usage

```heex
<.pagination
  current_page={@page}
  total_pages={@total_pages}
  page_url={fn page -> ~p"/projects?page=#{page}" end}
  link_mode="patch"
  window={2}
/>
```

`page_url` is a one-argument function. `link_mode` controls how the generated
URL is applied:

| Mode | Output | Use |
|------|--------|-----|
| `"href"` | `href` | Full navigation or non-LiveView pages |
| `"navigate"` | `navigate` | LiveView navigation to another page |
| `"patch"` | `patch` | Update the current LiveView URL and state |

The host LiveView remains responsible for reading the page parameter, loading
rows, and assigning `current_page` and `total_pages`.

## Custom labels

Use the `previous` and `next` slots to replace the default provider-agnostic
chevron controls. The `page` slot receives each page number through `:let`:

```heex
<.pagination current_page={2} total_pages={4} page_url={&"/items?page=#{&1}"} link_mode="href">
  <:page :let={page}>Page {page}</:page>
</.pagination>
```
