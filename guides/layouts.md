# Layout Primitives

PUI includes reusable shell primitives for documentation sites, dashboards, and
product workspaces without keeping sidebar collapse logic in application
templates.

## Components

- `PUI.Layout.app_layout/1` owns the root shell and the `data-collapsed` state.
- `PUI.Layout.sidebar/1` renders the sidebar surface with optional header/footer.
- `PUI.Layout.sidebar_menu_item/1` renders a row link or collapsible submenu.
- `PUI.Layout.content_header/1` renders the sticky header with breadcrumb and toggle.

## Initial collapse state

Pass `collapsed={true}` or a boolean assign to `app_layout/1` when the server
should render the sidebar collapsed on first paint:

```heex
<.app_layout id="docs-shell" collapsed={@sidebar_collapsed}>
  ...
</.app_layout>
```

PUI does not persist sidebar state or write cookies. When the user toggles the
shell, the bundled hook updates `data-collapsed` and dispatches a bubbling
`pui:sidebar-collapsed` event with `%{collapsed: boolean}` semantics in
`event.detail`. Applications can listen for that event and persist the value in
the place that matches their own session model, such as a cookie, user
preference, or browser storage.

## Example

```elixir
def render(assigns) do
  ~H"""
  <.app_layout id="docs-shell" content_class="p-0" collapsed={@sidebar_collapsed}>
    <:sidebar>
      <.sidebar>
        <:header>
          <div class="flex h-16 items-center border-b border-border px-4 font-semibold">
            PUI
          </div>
        </:header>

        <nav class="space-y-1 p-3">
          <.sidebar_menu_item
            title="Getting Started"
            icon="hero-rocket-launch"
            href="/docs/getting-started"
            current
          />

          <.sidebar_menu_item
            title="Components"
            icon="hero-squares-2x2"
            collapsible
            expanded
          >
            <:subitem>
              <.link href="/docs/button" class="block rounded-md px-2 py-1.5 text-sm hover:bg-accent">
                Button
              </.link>
            </:subitem>
            <:subitem>
              <.link href="/docs/dialog" class="block rounded-md px-2 py-1.5 text-sm hover:bg-accent">
                Dialog
              </.link>
            </:subitem>
          </.sidebar_menu_item>
        </nav>
      </.sidebar>
    </:sidebar>

    <:header>
      <.content_header
        shell_id="docs-shell"
        title="Docs"
        breadcrumb_parent="Guides"
        breadcrumb_current="Layouts"
      />
    </:header>

    <div class="p-6">
      <h1 class="text-2xl font-semibold">Layout primitives</h1>
      <p class="mt-2 text-muted-foreground">
        Compose your own shell while keeping collapse behavior inside PUI.
      </p>
    </div>
  </.app_layout>
  """
end
```

## JavaScript Hook

`sidebar_menu_item/1` uses the bundled `PUI.Sidebar` hook for submenu
expand/collapse behavior. If you already register `PUIHooks` in your
LiveSocket, no additional setup is required.
