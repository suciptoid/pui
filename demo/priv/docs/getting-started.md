%{
  title: "Getting Started",
  description: "Learn how to install and use PUI components in your Phoenix LiveView application.",
  group: "Getting Started",
  order: 0,
  icon: "hero-rocket-launch"
}
---

PUI is a comprehensive collection of Phoenix LiveView UI components built with Tailwind CSS. It provides beautiful, accessible, and highly customizable components that work seamlessly with Phoenix LiveView.

## Installation

Add `pui` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pui, "~> 1.0.0-alpha"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Setup

### 1. Import Components

Add `use PUI` to your LiveView modules to import all components:

```elixir
defmodule MyAppWeb.MyLive do
  use MyAppWeb, :live_view
  use PUI

  def render(assigns) do
    ~H"""
    <.button>Click me</.button>
    """
  end
end
```

### 2. Include CSS

Import the PUI stylesheet in your `app.css`:

```css
@import "../../deps/pui/assets/css/pui.css";
```

### 3. Include JavaScript Hooks

Add PUI hooks to your LiveSocket configuration in `app.js`:

```javascript
import { Hooks as PUIHooks } from "pui";

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...PUIHooks },
  params: { _csrf_token: csrfToken },
});
```

## Component Overview

PUI provides components in several categories:

| Category | Components |
|----------|-----------|
| **Forms** | Input, Select, Checkbox, Radio, Switch, Textarea |
| **Actions** | Button, Dropdown, Menu |
| **Overlays** | Dialog, Popover, Tooltip |
| **Feedback** | Alert, Toast/Flash, Loading |
| **Layout** | Container, Card, Header |
| **Data Display** | Progress, Badge |

## Design Principles

- **Accessible** — Built with WAI-ARIA patterns and keyboard navigation
- **Composable** — Mix and match components freely with slots
- **Customizable** — Override styles with Tailwind classes or use unstyled/headless variants
- **LiveView Native** — Designed specifically for Phoenix LiveView with server-side state management
