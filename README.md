<p align="center">
  <img src="demo/assets/pui-hook.png" alt="PUI Logo" width="200"/>
  <br>
  
  <a href="https://hex.pm/packages/pui">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/pui">
  </a>

  <a href="https://hexdocs.pm/pui">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT" src="https://img.shields.io/hexpm/l/pui">
  </a>
</p>

# PUI

PUI is a Phoenix LiveView UI toolkit with styled components, headless usage paths, and bundled JavaScript hooks for interactive primitives.

## Installation

Add `pui` to `mix.exs`:

```elixir
defp deps do
  [
    {:pui, "~> 1.0.0-beta.9"}
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
- `PUI.Alert`
- `PUI.Button`
- `PUI.ButtonGroup`
- `PUI.Chart`
- `PUI.Container`
- `PUI.DatePicker`
- `PUI.Dialog`
- `PUI.Dropdown`
- `PUI.Input`
- `PUI.Layout`
- `PUI.Popover`
- `PUI.Select`
- `PUI.Tabs`
- `PUI.Components` (shared UI helpers)

Additional modules available directly:

- `PUI.Flash` (flash/toast rendering and helpers)
- `PUI.Loading` (loading indicators)
- `PUI.MenuButton`

## Component Usage Levels

PUI supports three usage levels:

1. Low-level hooks (direct control):

```heex
<.popover_base phx-hook="PUI.Popover" data-placement="bottom">
  <.button>Trigger</.button>
  <:popup class="custom-popup">Content</:popup>
</.popover_base>
```

2. Unstyled variants (behavior, no default visuals):

```heex
<.menu_button variant="unstyled" class="my-btn">
  Open
  <:item class="my-item">Profile</:item>
</.menu_button>
```

3. Styled defaults (ready-to-use):

```heex
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>
```

## Guides

- [Usage Guide](guides/usage.md)
- [Headless Usage Guide](guides/headless-usage.md)
- [Layouts Guide](guides/layouts.md)
- [Migrate to PUI](guides/migrate-to-pui.md)

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
