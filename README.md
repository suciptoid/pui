<p align="center">
  <img src="demo/assets/pui-hook.png" alt="PUI Logo" width="200"/>
  <br />
  
  <a href="https://hex.pm/packages/pui">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/pui">
  </a>

  <a href="https://hexdocs.pm/pui">
    <img alt="Hex Docs" src="https://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT" src="https://img.shields.io/hexpm/l/pui">
  </a>
</p>

# PUI

PUI is a Phoenix LiveView UI toolkit with styled components and bundled JavaScript hooks. Hook-managed families also expose zero-style primitive parts for application-owned markup.

## Installation

Add `pui` to `mix.exs`:

```elixir
defp deps do
  [
    {:pui, "~> 1.0"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Setup in Your Phoenix App

Import PUI CSS in your app stylesheet:

```css
@import "tailwindcss" source(none);
@source "../css";
@source "../js";
@source "../../lib/your_app_web";
@source "../../deps/pui";
@import "../../deps/pui/assets/css/pui.css";
```

Register PUI hooks in your LiveSocket:

```javascript
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { Hooks as PUIHooks } from "pui";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { ...PUIHooks },
});

liveSocket.connect();
```

Use `PUI` in LiveView modules:

```elixir
defmodule MyAppWeb.DemoLive do
  use MyAppWeb, :live_view
  use PUI

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.button>Click me</.button>
      <.input type="text" placeholder="Name" />
    </div>
    """
  end
end
```

## Components Included by `use PUI`

- `PUI.Accordion`
- `PUI.Avatar`
- `PUI.Alert`
- `PUI.Badge`
- `PUI.Breadcrumb`
- `PUI.Button`
- `PUI.ButtonGroup`
- `PUI.Card`
- `PUI.Chart`
- `PUI.Container`
- `PUI.DatePicker`
- `PUI.Dialog`
- `PUI.Dropdown`
- `PUI.Empty`
- `PUI.Input`
- `PUI.Layout`
- `PUI.Pagination`
- `PUI.Popover`
- `PUI.Progress`
- `PUI.Select`
- `PUI.Separator`
- `PUI.Skeleton`
- `PUI.Table`
- `PUI.Tabs`
- `PUI.Components` (shared form and rendering helpers)

Additional modules available directly:

- `PUI.Flash` (flash/toast rendering and helpers)
- `PUI.Icon` and `PUI.IconProvider` (provider-agnostic semantic icons)
- `PUI.Loading` (loading indicators)
- `PUI.MenuButton`

## Component Usage

PUI is styled by default:

```heex
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>
```

For custom markup around a hook-managed interaction, import its explicit
primitive module instead of selecting an unstyled variant:

```heex
<PUI.Select.Primitive.root id="assignee">
  <PUI.Select.Primitive.trigger id="assignee-trigger" listbox_id="assignee-listbox">
    Choose an assignee
  </PUI.Select.Primitive.trigger>
</PUI.Select.Primitive.root>
```

## Guides

- [Usage Guide](guides/usage.md)
- [Icons Guide](guides/icons.md)
- [Breadcrumb Guide](guides/breadcrumb.md)
- [Pagination Guide](guides/pagination.md)
- [Empty Guide](guides/empty.md)
- [Separator Guide](guides/separator.md)
- [Skeleton Guide](guides/skeleton.md)
- [Avatar Guide](guides/avatar.md)
- [Headless Usage Guide](guides/headless-usage.md)
- [Layouts Guide](guides/layouts.md)
- [Migrate to PUI](guides/migrate-to-pui.md)

Project model:

- [Context glossary](CONTEXT.md)
- [Domain model](docs/domain-model.md)

## Development Commands

Build and setup:

- `mix setup`
- `mix assets.build`
- `mix dev`
- `mix build`
- `mix publish`

Testing and quality:

- `mix test`
- `mix test test/my_test.exs`
- `mix test test/my_test.exs:42`
- `mix test --failed`
- `mix compile`
- `mix format`
- `mix docs`
