---
name: pui-migrate
description: Migrate a Phoenix app from generated UI patterns (core_components and daisyUI class usage) to PUI primitives, theme tokens, and layout shells. Use when replacing `CoreComponents` calls, cleaning daisyUI classes from HEEx templates, adopting `use PUI`, and moving dashboard shells to `PUI.Layout`.
---

# PUI Migrate

Follow this workflow to migrate safely and keep behavior stable.

## 1. Map Existing UI Surfaces

Inventory the app before edits:

- Find generated wrappers and daisyUI-heavy templates.
- Identify dashboard shell files (`app.html.heex`, layout LiveViews, sidebar wrappers).
- List custom components that can be replaced with PUI equivalents.

Use quick discovery commands:

```bash
rg -n "CoreComponents|core_components|daisy|btn-|card-|alert-|input-" lib/*_web
rg -n "<\\.flash|<\\.button|<\\.input|<\\.modal|<\\.table" lib/*_web
```

## 2. Apply Baseline PUI Integration

Carry these setup steps before component replacement:

- Add `{:pui, "~> 1.0.0-alpha"}` to `mix.exs` and run `mix deps.get`.
- In `assets/css/app.css`, include PUI source and CSS import:
  - `@source "../../deps/pui";`
  - `@import "../../deps/pui/assets/css/pui.css";`
- In `assets/js/app.js`, merge PUI hooks:
  - `import { Hooks as PUIHooks } from "pui";`
  - `hooks: %{...PUIHooks, ...}` in `LiveSocket` config.
- Enable PUI usage in LiveViews with `use PUI` (or import selected modules in `*_web.ex`).

## 3. Enable PUI Imports and Base Theme

- Add the dependency and fetch deps.
- Use `use PUI` in LiveView modules or import specific modules in `*_web.ex`.
- Keep project-level theme variables in CSS and use semantic names (`primary`, `secondary`, `accent`, `destructive`).

Example:

```elixir
def live_view do
  quote do
    use Phoenix.LiveView
    use PUI
  end
end
```

## 4. Replace Generated Components Incrementally

Do replacements in focused slices:

- Forms: `<.input>` and helpers -> `PUI.Input`
- Buttons/actions -> `PUI.Button`
- Flash/loading -> `PUI.Flash.flash_group` and `PUI.Loading.topbar`
- Dialog/dropdown/popover wrappers -> PUI modules

Apply one slice, compile, and test before the next slice.

## 5. Remove DaisyUI and Dead Wrappers

- Replace utility classes that exist only for daisyUI components.
- Delete now-unused wrapper functions in `core_components.ex`.
- Remove obsolete imports/usages and references.

## 6. Move App Shell to `PUI.Layout`

For dashboard-style apps:

- Use `PUI.Layout.app_layout/1` as the root shell.
- Compose sidebar sections with `PUI.Layout.sidebar/1` and `sidebar_menu_item/1`.
- Use `PUI.Layout.content_header/1` for header controls.

Keep public/auth surfaces split as needed by the host app.

## 7. Validate and Clean Up

Run:

```bash
mix compile
mix test
mix format
```

Confirm there are no remaining generated-component hooks:

```bash
rg -n "CoreComponents|core_components|daisy|<\\.flash|<\\.modal" lib/*_web
```

## References

- Read [`references/migration-checklist.md`](references/migration-checklist.md) for a compact execution checklist.
- Read [`references/component-mapping.md`](references/component-mapping.md) for common replacement patterns.
