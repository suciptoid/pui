%{
  title: "Headless Components",
  description: "Use PUI as low-level hooks or unstyled primitives when you need complete control over presentation.",
  group: "Getting Started",
  order: 1,
  icon: "hero-adjustments-horizontal"
}
---

PUI supports three usage levels, so you can choose how much styling or markup it owns. Use this guide as a reference for wiring it into your own design system.

## Usage Levels

### Level 1: Low-level Hooks

Use low-level primitives such as `popover_base` when you want to own the trigger markup, popup container, and every utility class yourself.

```heex
<.popover_base phx-hook="PUI.Popover" data-placement="bottom-start">
  <:trigger class="my-trigger">Open custom popover</:trigger>
  <:popup class="aria-hidden:hidden block my-popover">
    Custom content
  </:popup>
</.popover_base>
```

<AppWeb.DocsDemo.headless_popover_demo />

### Level 2: Unstyled Components

Use `variant="unstyled"` when you want PUI to keep the component behavior and accessibility, but you want full control over the classes applied to the trigger, content, or slots.

```heex
<.menu_button
  variant="unstyled"
  class="my-trigger"
  content_class="aria-hidden:hidden block my-menu"
>
  Actions
  <:item class="my-menu-item">Profile</:item>
  <:item class="my-menu-item">Settings</:item>
</.menu_button>
```

<AppWeb.DocsDemo.headless_unstyled_demo />

### Level 3: Styled Components

Use the default component variants when you want a polished starting point with minimal setup.

```heex
<.button variant="secondary">Save changes</.button>
```

## Unstyled Button

Buttons support `variant="unstyled"` so you can provide your own utility classes.

```heex
<.button
  variant="unstyled"
  class="inline-flex items-center rounded-xl bg-zinc-950 px-4 py-2 text-sm font-medium text-white"
>
  Custom Trigger
</.button>
```

## Unstyled Menu Button

`menu_button` keeps the trigger semantics, keyboard navigation, and menu roles while letting you style the trigger, menu, and each item independently.

```heex
<.menu_button
  variant="unstyled"
  class="inline-flex items-center gap-2 rounded-xl border px-4 py-2"
  content_class="aria-hidden:hidden block min-w-48 rounded-xl border bg-background p-1 shadow-xl"
>
  Custom Menu
  <:item class="flex items-center gap-2 rounded-lg px-3 py-2 hover:bg-accent">
    <.icon name="hero-user" class="size-4" /> Profile
  </:item>
  <:item class="flex items-center gap-2 rounded-lg px-3 py-2 hover:bg-accent">
    <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
  </:item>
</.menu_button>
```

## Unstyled Dialog

Dialogs also support `variant="unstyled"`. Supply the backdrop classes on the dialog itself, and render your custom panel inside the dialog body.

```heex
<.button phx-click="open-dialog">Open dialog</.button>

<.dialog
  id="custom-dialog"
  variant="unstyled"
  class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 px-4 [hidden]:hidden"
  show={@show_dialog}
  on_cancel={JS.push("close-dialog")}
>
  <div class="w-full max-w-lg rounded-2xl border border-border bg-background p-6 shadow-2xl">
    <h3 class="text-lg font-semibold">Bring your own panel styles</h3>
    <p class="mt-2 text-sm text-muted-foreground">
      PUI still manages focus, escape handling, and dismissal behavior.
    </p>
  </div>
</.dialog>
```

## Visibility Handling

Headless and unstyled components still need a visibility strategy that matches the attributes PUI toggles for each primitive.

### Popover, Dropdown, and Select

Popovers, dropdowns, and select menus toggle `aria-hidden`. Add `aria-hidden:hidden` to hide content when it is closed, plus your normal open-state display classes.

```heex
content_class="aria-hidden:hidden block rounded-xl border bg-background p-1 shadow-xl"
```

### Tooltips

Tooltips typically combine `aria-hidden` with opacity and visibility classes so they can animate smoothly.

```heex
class="aria-hidden:opacity-0 not-aria-hidden:opacity-100
  aria-hidden:pointer-events-none invisible not-aria-hidden:visible
  transition-opacity duration-100"
```

### Dialog

Dialogs use the HTML `hidden` attribute instead of `aria-hidden`, so backdrop and content styles should account for `[hidden]`.

```heex
class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 px-4 [hidden]:hidden"
```

## Feature Comparison

| Feature | Low-level Hooks | Unstyled | Styled |
|---------|-----------------|----------|--------|
| Default styling | No | No | Yes |
| Floating UI behavior | Direct access | Built in | Built in |
| ARIA and keyboard support | Manual | Built in | Built in |
| Custom markup control | Full | High | Low |
| Best for | Custom primitives | Design systems | Fast delivery |

## Accessibility and Behavior

All three levels keep the same accessibility goals, but they divide responsibility differently:

- Low-level hooks give you raw behavior primitives and expect you to supply semantics and styling.
- Unstyled components preserve the ARIA attributes, keyboard handling, focus behavior, and dismissal logic while leaving presentation up to you.
- Styled components add the default visual system on top of the same core behavior.

If you want the fastest path to a custom design system, start with `variant="unstyled"` and only drop down to low-level hooks when you need fully custom markup.
