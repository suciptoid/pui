# PUI - Phoenix LiveView UI Toolkit

## Commands

### Build & Setup
- **Setup project**: `mix setup` (installs deps and builds assets)
- **Build assets**: `mix assets.build`
- **Watch assets**: `mix dev` (watches for JS/CSS changes)
- **Build package**: `mix build` (assets + hex package)
- **Publish**: `mix publish` (build + publish to Hex)

### Testing
- **Run all tests**: `mix test`
- **Run single test file**: `mix test test/my_test.exs`
- **Run test at specific line**: `mix test test/my_test.exs:42`
- **Run failed tests only**: `mix test --failed`

### Code Quality
- **Format code**: `mix format`
- **Check compilation**: `mix compile`
- **Generate docs**: `mix docs`

## Architecture

- **lib/pui.ex**: Main module with `use PUI` macro that imports all components
- **lib/pui/**: UI components (Button, Input, Select, Dialog, Dropdown, Alert, Popover, etc.)
- **assets/**: JS hooks and CSS for client-side functionality
- **demo/**: Phoenix app showcasing components (see demo/AGENTS.md for Phoenix guidelines)

# Docs / References
use command `mix run -e "require IEx.Helpers; IEx.Helpers.h(PUI.Dialog)"` to read the docs for the `PUI.Dialog` module or another module from library / elixir built-in modules.

## Code Style

### General Elixir
- Target Elixir ~> 1.15, Phoenix LiveView ~> 1.1
- Never nest multiple modules in one file
- Use `Enum.at/2` for list index access, never `list[i]`
- Bind block expression results (`if`/`case`/`cond`) to variables
- Predicate functions end with `?` (not `is_` prefix)
- Don't use `String.to_atom/1` on user input (memory leak risk)

### Component Structure
- Use `Phoenix.Component` with `~H` sigil for HEEx templates
- Always declare `attr` and `slot` before function definitions
- Components should have comprehensive `@moduledoc` with usage examples
- Include attributes table in documentation

```elixir
defmodule PUI.Button do
  use Phoenix.Component

  attr :class, :string, default: ""
  attr :variant, :string, values: ["default", "secondary"], default: "default"
  attr :rest, :global, include: ~w(href navigate patch disabled)
  slot :inner_block, required: true

  def button(assigns) do
    # Implementation
  end
end
```


### Form Components
- Accept `field` attribute of type `Phoenix.HTML.FormField`
- Use `map_field/1` helper to normalize field attributes
- Support both form field and direct value inputs

### Component Registration
- Add new components to `lib/pui.ex` in the `__using__` macro
- Export public functions via `defdelegate` when needed

## File Organization

- One component module per file
- Component name matches file name (e.g., `PUI.Button` in `button.ex`)
- Shared utilities go in `lib/pui/components.ex` or dedicated modules
- CSS variables use semantic naming: `primary`, `secondary`, `destructive`, `accent`

## Documentation Standards

- All public functions must have `@moduledoc` with:
  - Brief description
  - Usage examples
  - Attributes table (name, type, default, description)
  - Slots table if applicable
- Include examples showing all variants and common use cases


## Assets

- JavaScript hooks in `assets/js/hooks/`
- CSS in `assets/css/`
- Built with esbuild (configured in mix.exs)
- Components requiring JS hooks must document `phx-hook` usage
