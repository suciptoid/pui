%{
  title: "Migrate Phoenix UI To PUI",
  description: "Move from Phoenix generator UI and core components to PUI primitives, flash, loading, and layout components.",
  group: "Getting Started",
  order: 2,
  icon: "hero-arrow-path"
}
---

This guide covers the practical migration path from the default `phx.new` UI
layer to PUI.

## What to replace

- Generated `core_components.ex` helpers such as custom flash, button, input, and icon wrappers
- `phx.new` layout markup like the topbar, flash area, and generated shell structure
- App-local sidebar or submenu hooks that can move into bundled PUI hooks

## Core migration steps

### 1. Import PUI in shared web entrypoints

```elixir
def live_view do
  quote do
    use Phoenix.LiveView
    use PUI
  end
end
```

### 2. Replace generated flash and loading UI

```heex
<PUI.Loading.topbar />
<PUI.Flash.flash_group flash={@flash} />
```

Use `live={true}` only inside LiveView-rendered trees. Shared layouts that also
render controller templates should use the default non-live flash group.

### 3. Move app shell markup to `PUI.Layout`

```heex
<.app_layout id="app-shell">
  <:sidebar>
    <.sidebar>
      ...
    </.sidebar>
  </:sidebar>

  <:header>
    <.content_header shell_id="app-shell" breadcrumb_current="Dashboard" />
  </:header>

  ...
</.app_layout>
```

### 4. Remove app-local submenu hooks

If you were relying on a colocated sidebar collapse hook, move to
`sidebar_menu_item/1` and the bundled `PUI.Sidebar` hook by registering
`PUIHooks` in your LiveSocket.

## Example target

Open the full-page demo to see how the generated layout, topbar, sidebar, and
local submenu hook can collapse into reusable PUI primitives:

[Open app layout demo](/demo/layout-app)

## Notes

- Migrate incrementally and compile after each phase.
- Replace generated auth and layout UI with plain HEEx plus PUI primitives rather than re-creating `phx.new` helper wrappers.
- Keep app-specific copy and information architecture local; use PUI for behavior and surfaces.
