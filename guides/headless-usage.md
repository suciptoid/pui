# Headless Component Usage

PUI supports three levels of component usage, from fully styled to completely custom.

## Level 1: Low-level Hooks (Direct Floating UI)

For maximum control, use the low-level hooks directly with Floating UI:

```elixir
<.popover_base phx-hook="PUI.Popover" data-placement="bottom">
  <.button class="your-custom-classes">Trigger</.button>
  <:popup class="your-popup-classes">
    Custom content with full control
  </:popup>
</.popover_base>
```

### Available Hooks

- `PUI.Popover` - Popover/dropdown positioning
- `PUI.Tooltip` - Tooltip positioning
- `PUI.Select` - Select dropdown with search

### Hook Configuration

Hooks accept data attributes for configuration:

```elixir
<.popover_base 
  phx-hook="PUI.Popover"
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

## Handling Visibility

Unstyled components require you to provide visibility classes. Here are the patterns used by styled components:

### Popover/Dropdown Visibility

Popovers use `aria-hidden` for visibility control. Your custom classes must include:

```elixir
<.menu_button 
  variant="unstyled" 
  content_class="aria-hidden:hidden block bg-white border rounded shadow"
>
  Open
  <:item class="px-4 py-2 hover:bg-gray-100">Item</:item>
</.menu_button>
```

**Required visibility classes:**
- `aria-hidden:hidden` - Hides content when `aria-hidden="true"`
- `block` - Makes content visible when shown (or your preferred display)

**With animations:**
```elixir
content_class="aria-hidden:hidden block bg-white border rounded shadow
  not-aria-hidden:animate-in aria-hidden:animate-out
  not-aria-hidden:fade-in-0 aria-hidden:fade-out-0
  not-aria-hidden:zoom-in-95 aria-hidden:zoom-out-95"
```

### Tooltip Visibility

Tooltips also use `aria-hidden` with opacity and visibility transitions:

```elixir
<.tooltip variant="unstyled" class="bg-gray-900 text-white px-3 py-1.5 rounded text-sm
  aria-hidden:opacity-0 not-aria-hidden:opacity-100
  aria-hidden:pointer-events-none
  invisible not-aria-hidden:visible
  transition-opacity duration-100"
>
  <.button>Hover me</.button>
  <:tooltip>Tooltip text</:tooltip>
</.tooltip>
```

**Required visibility classes:**
- `aria-hidden:opacity-0` / `not-aria-hidden:opacity-100` - Fade transition
- `aria-hidden:pointer-events-none` - Prevent interaction when hidden
- `invisible not-aria-hidden:visible` - Proper visibility toggle

**With directional slide animation:**
```elixir
class="bg-gray-900 text-white px-3 py-1.5 rounded
  aria-hidden:opacity-0 not-aria-hidden:opacity-100
  aria-hidden:pointer-events-none
  invisible not-aria-hidden:visible
  transition-all duration-100
  data-[placement=top]:aria-hidden:translate-y-2
  data-[placement=bottom]:aria-hidden:-translate-y-2
  data-[placement=left]:aria-hidden:translate-x-2
  data-[placement=right]:aria-hidden:-translate-x-2"
```

### Dialog Visibility

Dialogs use the `hidden` HTML attribute (not `aria-hidden`). Apply classes with `[hidden]` and `not-[hidden]`:

**Backdrop:**
```elixir
<.dialog variant="unstyled" class="fixed inset-0 bg-black/50 flex items-center justify-center
  not-[hidden]:animate-in [hidden]:animate-out
  not-[hidden]:fade-in-0 [hidden]:fade-out-0"
  id="my-dialog" show={@show_dialog}
>
  ...
</.dialog>
```

**Dialog content:**
```elixir
<.dialog variant="unstyled" class="bg-white p-6 rounded-lg shadow-xl max-w-md
  not-[hidden]:animate-in [hidden]:animate-out
  not-[hidden]:fade-in-0 [hidden]:fade-out-0
  not-[hidden]:zoom-in-95 [hidden]:zoom-out-95"
  id="my-dialog" show={@show_dialog}
>
  ...
</.dialog>
```

**Simple visibility (no animation):**
```elixir
<.dialog variant="unstyled" class="fixed inset-0 bg-black/50 [hidden]:hidden" id="my-dialog">
  <div class="bg-white p-6 rounded-lg">
    Content
  </div>
</.dialog>
```

### Select Visibility

Select dropdowns use the same pattern as popovers:

```elixir
<.select variant="unstyled" class="border rounded px-3 py-2">
  <.select_item value="a" class="px-4 py-2 hover:bg-gray-100">Option A</.select_item>
</.select>
```

The dropdown menu needs visibility classes applied to its container.

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