# Headless Component Usage

Maui supports three levels of component usage, from fully styled to completely custom.

## Level 1: Low-level Hooks (Direct Floating UI)

For maximum control, use the low-level hooks directly with Floating UI:

```elixir
<.popover_base phx-hook="Maui.Popover" data-placement="bottom">
  <.button class="your-custom-classes">Trigger</.button>
  <:popup class="your-popup-classes">
    Custom content with full control
  </:popup>
</.popover_base>
```

### Available Hooks

- `Maui.Popover` - Popover/dropdown positioning
- `Maui.Tooltip` - Tooltip positioning
- `Maui.Select` - Select dropdown with search

### Hook Configuration

Hooks accept data attributes for configuration:

```elixir
<.popover_base 
  phx-hook="Maui.Popover"
  data-placement="top"
  data-trigger="hover"
  data-strategy="fixed"
>
  ...
</.popover_base>
```

## Level 2: Unstyled Components

Use `variant="unstyled"` to get component behavior without styling:

```elixir
<.menu_button variant="unstyled" class="px-4 py-2 bg-blue-500 text-white">
  Open Menu
  <:item class="px-4 py-2 hover:bg-gray-100">Profile</:item>
  <:item class="px-4 py-2 hover:bg-gray-100">Settings</:item>
</.menu_button>
```

### Available Unstyled Components

All components support `variant="unstyled"`:

- `button`
- `menu_button`
- `tooltip`
- `dialog`
- `select`
- `alert`

### Slot Classes

Each slot accepts a `class` attribute:

```elixir
<.menu_button variant="unstyled">
  Open
  <:item class="my-item-class">Item 1</:item>
</.menu_button>

<.dialog variant="unstyled" class="my-dialog">
  <:trigger :let={attr}>
    <button {attr} class="my-trigger">Open</button>
  </:trigger>
  <p class="my-content">Dialog content</p>
</.dialog>
```

## Level 3: Styled Components

Default styled components with Tailwind classes:

```elixir
<.menu_button variant="secondary" class="w-full">
  Open Menu
  <:item>Profile</:item>
</.menu_button>
```

### Customizing Styled Components

Use `class` to extend or override styles:

```elixir
<.button variant="secondary" class="w-full !bg-red-500">
  Full Width Red Button
</.button>
```

## Migration Guide

### From Styled to Unstyled

1. Add `variant="unstyled"` to component
2. Add custom classes to component and slots
3. Maintain any `phx-*` attributes for interactivity

```elixir
# Before
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>

# After
<.menu_button variant="unstyled" class="btn btn-secondary">
  Open
  <:item class="menu-item">Profile</:item>
</.menu_button>
```

### CSS Framework Compatibility

Unstyled components work with any CSS framework:

**Bootstrap:**
```elixir
<.button variant="unstyled" class="btn btn-primary">
  Bootstrap Button
</.button>
```

**Tailwind Custom:**
```elixir
<.button variant="unstyled" class="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500">
  Custom Gradient
</.button>
```

**CSS Modules:**
```elixir
<.button variant="unstyled" class={@styles.button}>
  CSS Module Button
</.button>
```

## ARIA and Accessibility

Unstyled components preserve all ARIA attributes:

```elixir
<.menu_button variant="unstyled">
  <!-- Still has aria-haspopup, aria-expanded, role="menu", etc. -->
  Open
  <:item>Profile</:item>
</.menu_button>
```

All three usage levels maintain proper accessibility.