%{
  title: "Layout",
  description: "Compose reusable documentation and dashboard shells with PUI layout primitives.",
  group: "Layout",
  order: 10,
  icon: "hero-view-columns"
}
---

`PUI.Layout` gives you a reusable shell for docs, dashboards, and internal tools
without scattering collapse logic across app-specific templates.

## Included primitives

- `app_layout/1` owns the root shell and collapsed sidebar state.
- `sidebar/1` renders a configurable sidebar surface.
- `sidebar_menu_item/1` renders a nav row with optional collapsible submenu.
- `content_header/1` renders a sticky header with breadcrumb and shell toggle.

## Import

All layout primitives are available through:

```elixir
use PUI
```

## Example

```heex
<.app_layout id="workspace-shell" content_class="p-0">
  <:sidebar>
    <.sidebar>
      <:header>
        <div class="flex h-16 items-center border-b border-border px-4 font-semibold">
          Workspace
        </div>
      </:header>

      <nav class="space-y-1 p-3">
        <.sidebar_menu_item title="Overview" icon="hero-home" href="/overview" current />
        <.sidebar_menu_item title="Settings" icon="hero-cog-6-tooth" href="/settings" />
      </nav>
    </.sidebar>
  </:sidebar>

  <:header>
    <.content_header
      shell_id="workspace-shell"
      title="Admin"
      breadcrumb_parent="Console"
      breadcrumb_current="Overview"
    />
  </:header>

  <section class="p-6">
    ...
  </section>
</.app_layout>
```

## Full-page demo

The application shell needs real viewport space to be evaluated properly. Open
the dedicated demo page instead of viewing it inside a constrained docs frame:

[Open app layout demo](/demo/layout-app)
