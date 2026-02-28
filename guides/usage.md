# Maui Usage Guide

This guide will help you integrate Maui into your Phoenix LiveView application.

## Installation

### 1. Add Maui to your dependencies

Add `maui` to your `mix.exs`:

```elixir
defp deps do
  [
    {:maui, "~> 1.0.0-alpha"}
  ]
end
```

Then run:

```bash
mix deps.get
```

### 2. Configure CSS

Import Maui's CSS into your application's CSS file (e.g., `assets/css/app.css`):

```css
@import "tailwindcss" source(none);
@source "../css";
@source "../js";
@source "../../lib/your_app_web";

/* Add Maui source path */
@source "../../../lib/maui";
@import "../../../assets/css/maui.css";

/* Your other imports... */
```

### 3. Configure JavaScript Hooks

Import Maui's JavaScript hooks in your `assets/js/app.js`:

```javascript
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { Hooks as MauiHooks } from "maui";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    ...MauiHooks,
    // Your other hooks...
  },
});

liveSocket.connect();
```

### 4. Use Maui in Your LiveViews

Add `use Maui` to your LiveView modules to import all components:

```elixir
defmodule MyAppWeb.DemoLive do
  use MyAppWeb, :live_view
  use Maui

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.button>Click me</.button>
      <.input type="text" placeholder="Enter text" />
    </div>
    """
  end
end
```

## Components Overview

Maui provides the following components:

### Button

```heex
<.button>Default Button</.button>
<.button variant="secondary">Secondary</.button>
<.button variant="destructive">Delete</.button>
<.button variant="outline">Outline</.button>
<.button variant="ghost">Ghost</.button>
<.button variant="link">Link</.button>

<!-- Sizes -->
<.button size="sm">Small</.button>
<.button size="default">Default</.button>
<.button size="lg">Large</.button>
<.button size="icon">
  <.icon name="hero-heart" class="w-4 h-4" />
</.button>

<!-- With navigation -->
<.button navigate={~p"/path"}>Navigate</.button>
<.button patch={~p"/path"}>Patch</.button>
<.button href={~p"/path"}>Link</.button>
```

### Input

```heex
<!-- Basic inputs -->
<.input type="text" placeholder="Enter text" label="Name" />
<.input type="password" placeholder="Enter password" label="Password" />
<.input type="email" placeholder="you@example.com" label="Email" />
<.input type="file" label="Upload file" />

<!-- With Phoenix forms -->
<.form for={@form} phx-change="validate">
  <.input field={@form[:name]} placeholder="Enter your name" />
  <.input field={@form[:email]} type="email" />
</.form>

<!-- Textarea -->
<.textarea field={@form[:description]} placeholder="Enter description..." />

<!-- Checkbox -->
<.checkbox id="terms" label="Agree to terms" />
<.checkbox id="newsletter" label="Subscribe to newsletter" checked />

<!-- Radio buttons -->
<.label class="flex items-center gap-2">
  <.radio name="plan" value="basic" /> Basic
</.label>
<.label class="flex items-center gap-2">
  <.radio name="plan" value="pro" /> Pro
</.label>

<!-- Switch/Toggle -->
<.switch id="notifications" label="Enable notifications" />
```

### Dropdown Menu

```heex
<Maui.Dropdown.menu_button content_class="w-52">
  <.icon name="hero-user" class="size-4" /> Update Profile
  
  <:item navigate="/profile" shortcut="⇧⌘P">
    <.icon name="hero-user" class="size-4" /> Profile
  </:item>
  <:item shortcut="⌘S">
    <.icon name="hero-cog" class="size-4" /> Settings
  </:item>
  <:item variant="destructive">
    <.icon name="hero-trash" class="size-4" /> Delete
  </:item>
</Maui.Dropdown.menu_button>

<!-- With custom items -->
<Maui.Dropdown.menu_button content_class="w-52">
  Options
  <:items>
    <.link navigate="/profile" role="menuitem">Profile</.link>
    <Maui.Dropdown.menu_item>Settings</Maui.Dropdown.menu_item>
    <Maui.Dropdown.menu_separator />
    <Maui.Dropdown.menu_item variant="destructive">
      <.icon name="hero-trash" class="size-4" /> Delete
    </Maui.Dropdown.menu_item>
  </:items>
</Maui.Dropdown.menu_button>
```

### Alert

```heex
<Maui.Alert.alert>
  <:icon>
    <.icon name="hero-check-circle" class="size-5" />
  </:icon>
  <:title>Success!</:title>
  <:description>Your changes have been saved.</:description>
</Maui.Alert.alert>

<!-- Destructive variant -->
<Maui.Alert.alert variant="destructive">
  <:icon>
    <.icon name="hero-exclamation-triangle" class="size-5" />
  </:icon>
  <:title>Error</:title>
  <:description>Something went wrong.</:description>
</Maui.Alert.alert>
```

### Popover

```heex
<Maui.Popover.base
  id="demo-popover"
  phx-hook="Maui.Popover"
  data-placement="top"
>
  <.button aria-haspopup="menu">Click Me</.button>
  
  <:popup class="min-w-[250px] bg-foreground text-primary-foreground rounded-md shadow-md p-4">
    <div class="space-y-2">
      <p class="font-medium">Popover Content</p>
      <p class="text-sm opacity-90">This is a popover with custom content.</p>
    </div>
  </:popup>
</Maui.Popover.base>
```

### Toast/Flash Notifications

Add the flash group component to your layout:

```heex
<Maui.Flash.flash_group
  flash={@flash}
  position="top-right"
  live={true}
/>
```

Send flash messages from your LiveView:

```elixir
# Basic flash message
Maui.Flash.send_flash("Operation completed successfully!")

# Custom flash with HTML content
Maui.Flash.send_flash(~H"""
  <div class="flex items-center gap-2">
    <.icon name="hero-check-circle" class="size-5" />
    <span>Success!</span>
  </div>
""")

# Advanced flash with custom options
Maui.Flash.send_flash(%Maui.Flash.Message{
  id: "my-flash",
  type: :info,
  message: "Custom message",
  duration: 8,  # seconds, -1 for no auto-dismiss
  show_close: true,
  class: "border-green-500 bg-green-100 text-green-800"
})
```

### Progress & Badge

```heex
<!-- Progress bar -->
<Maui.Components.progress value={75} />
<Maui.Components.progress value={45} class="h-4" />

<!-- Badge -->
<Maui.Components.badge>Default</Maui.Components.badge>
<Maui.Components.badge variant="secondary">Secondary</Maui.Components.badge>
<Maui.Components.badge variant="destructive">Error</Maui.Components.badge>
<Maui.Components.badge variant="outline">Outline</Maui.Components.badge>
```

### Dialog

```heex
<Maui.Dialog.dialog id="confirm-dialog">
  <:trigger>
    <.button>Open Dialog</.button>
  </:trigger>
  
  <:content>
    <Maui.Dialog.header>
      <Maui.Dialog.title>Are you sure?</Maui.Dialog.title>
      <Maui.Dialog.description>
        This action cannot be undone.
      </Maui.Dialog.description>
    </Maui.Dialog.header>
    
    <div class="flex justify-end gap-2 mt-4">
      <.button variant="outline" phx-click={Maui.Dialog.dismiss("confirm-dialog")}>
        Cancel
      </.button>
      <.button variant="destructive" phx-click="confirm">
        Delete
      </.button>
    </div>
  </:content>
</Maui.Dialog.dialog>
```

### Select

```heex
<Maui.Select.select
  id="country-select"
  options={[
    %{value: "us", label: "United States"},
    %{value: "uk", label: "United Kingdom"},
    %{value: "jp", label: "Japan"}
  ]}
  placeholder="Select a country"
/>
```

## Global Component Imports

To make Maui components available in all your LiveViews without adding `use Maui` to each one, add the imports to your `my_app_web.ex` file:

```elixir
defmodule MyAppWeb do
  # ...

  defp html_helpers do
    quote do
      # ... other imports
      
      # Import Maui components globally
      import Maui
      import Maui.Input
      import Maui.Button
      import Maui.Dropdown
      import Maui.Alert
      import Maui.Popover
      import Maui.Select
      import Maui.Dialog
      import Maui.Components
    end
  end
end
```

## Customization

Maui components use Tailwind CSS classes and can be customized via the `class` attribute:

```heex
<.button class="bg-purple-600 hover:bg-purple-700">
  Custom Purple Button
</.button>

<.input class="border-blue-500 focus:ring-blue-500" />
```

## Dependencies

Maui requires:

- Phoenix LiveView ~> 1.1
- Tailwind CSS v4
- esbuild for JavaScript bundling

## Demo Application

Check out the `demo/` directory in the Maui repository for a complete example application showcasing all components.

To run the demo:

```bash
cd demo
mix setup
mix phx.server
```

Then visit `http://localhost:4000` to see all components in action.
