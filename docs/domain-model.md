# PUI Domain Model

PUI is a reusable UI composition context for Phoenix LiveView. Its boundary is the interface between a host application's server-rendered view state and the browser's interactive presentation layer.

PUI does not own business entities, persistence, authorization, routing policy, or application workflows. A host application owns those concerns and supplies values, events, form state, and business meaning to PUI.

## Context boundary

| Participant | Owns | Hands across the boundary |
| --- | --- | --- |
| Host application | Business meaning, LiveView state, events, forms, and persistence | Assigns, slots, IDs, values, JS commands, and event handlers |
| PUI server components | HTML structure, semantic relationships, default presentation, normalization, and server-facing value plumbing | Rendered markup, ARIA state, `data-*` markers, hidden fields, and hook declarations |
| PUI browser hooks | Ephemeral interaction, focus, keyboard navigation, positioning, resizing, animation state, and client-only persistence | Native events, custom PUI events, LiveView events, and DOM state |
| Host application's design system | Brand presentation, icon vocabulary, and application-specific composition | CSS variables, utility classes, icon providers, custom slots, and unstyled-component classes |

The boundary is intentionally not a client/server ownership split for every value. A selected form value may be server-owned while the open state of the select popup is browser-owned. The important question is whether the state must participate in LiveView rendering and application behavior.

## Component taxonomy

| Area | Component families | Primary responsibility |
| --- | --- | --- |
| Composition and structure | Accordion, ButtonGroup, Card, Container, Layout | Group content and actions into reusable structural shapes |
| Actions and navigation | Button, Dropdown | Provide actionable controls, links, menu triggers, and menu items |
| Forms | Input, Select, DatePicker | Render field-aware controls, normalize values, and expose validation feedback |
| Disclosure and overlays | Dialog, Popover, Tooltip, Tabs | Coordinate triggers, content, focus, visibility, and relationships |
| Feedback | Alert, Badge, Flash, Loading, Progress | Communicate status, transient messages, progress, and loading |
| Data display | Badge, Progress, Table | Present compact labels, completion values, and collections |
| Data visualization | Chart, BarChart, LineChart | Render serializable chart configuration and data through browser chart hooks |
| Shared vocabulary | Components, icon provider | Supply small cross-family presentation and error helpers while leaving icon-library choice to the host |

Accordion is the native-behavior exception within the interactive families: it uses `<details>` and `<summary>` so its core expand/collapse behavior does not require a JavaScript hook. Other richer interactions are progressively enhanced with hooks or LiveView JS commands.

Tables are presentation primitives rather than data-querying components. A table can render ordinary lists or LiveView streams and expose row/slot callbacks, but the host application owns sorting, filtering, pagination, authorization, and data loading.

## Three usage levels

PUI exposes one composition model at three levels:

1. **Styled** — use a component's default visual treatment and customize it with supported attributes and classes.
2. **Unstyled/headless** — retain PUI's structure and interaction semantics while supplying the visual treatment, including visibility classes where the host owns them.
3. **Low-level hook** — compose the surrounding markup directly and satisfy the hook contract yourself.

The levels are not separate product lines. They are points on the same spectrum of responsibility: PUI supplies more presentation at the styled level and transfers more markup and styling responsibility to the host at the low-level end.

## Composition rules

PUI component families generally follow these rules:

- The outer primitive establishes the relationship and state boundary.
- Slots provide consumer-owned content without requiring a host wrapper to duplicate the family structure.
- IDs connect triggers, content, labels, panels, and hidden form fields.
- Roles and ARIA attributes remain part of the component contract in unstyled mode.
- A class passed to a styled component augments its default presentation; an unstyled component treats consumer classes as its visual implementation.
- Global attributes are forwarded only where the component's public contract allows them.
- PUI-owned icon intent crosses the host boundary as an icon token; application-owned icons cross it as slot content.

For hook-backed families, the markup is an API. A change to a `data-pui` marker, derived ID, hook name, role, or event name can break browser behavior even when the rendered HTML still looks correct.

## State ownership and lifecycle

### Server-owned values

The server owns values that must be submitted, validated, rendered into a new LiveView state, or observed by application code. Field-backed inputs derive identity and values from `Phoenix.HTML.FormField`. Selects and date pickers expose their current selection through form-compatible inputs and native `change` events. Dialogs can also be controlled by a server `show` value and an `on_cancel` command that keeps server state aligned when the user dismisses the dialog in the browser.

### Browser-owned interaction

Hooks own short-lived interaction details: popup placement, outside-click handling, keyboard roving focus, active descendants, tooltip positioning, chart measurement, loading-bar progress, and sidebar collapse persistence. These values are restored or recalculated during the hook lifecycle rather than becoming application state by default.

### LiveView patch lifecycle

Hook-backed components must tolerate the full lifecycle:

1. `mounted` discovers the component's semantic elements and binds listeners.
2. `updated` rereads server-rendered attributes, restores relevant browser state, and rebinds if the DOM changed.
3. `destroyed` removes listeners, observers, timers, and floating-positioning resources.

This lifecycle is why stable IDs and marker attributes matter. The server may replace or patch the markup while the browser interaction is open.

## Core interaction workflows

### Overlay workflow

The component renders a trigger/content relationship and a hook or JS command controls open state, focus, and positioning. The hook updates ARIA state and restores focus on close; the host application may additionally send a LiveView event when the business workflow needs to know that the overlay was dismissed.

This covers popovers, dropdowns, tooltips, selects, and date pickers, with dialog adding focus wrapping and server-controlled visibility.

### Form workflow

The host supplies either a field-backed control or explicit values. PUI normalizes identity and values, renders the semantic control and validation feedback, and lets the browser emit native `input`/`change` events. The host form or LiveView decides what validation or business action follows.

Select and date-picker implementations may use hidden native inputs because the visible trigger is not itself the submitted form control. Those hidden inputs are part of the public behavior contract, not an implementation detail consumers should replace.

### Feedback workflow

The host application creates an alert, flash message, loading state, progress value, or badge value. PUI renders it and, where appropriate, manages display-only behavior such as auto-dismissal, streaming updates, close controls, or a transition loading bar. PUI does not infer why the status exists.

### Layout workflow

The host composes a layout shell from structural primitives. Sidebar collapse and submenu expansion are browser interaction state with a small synchronization seam: the hook can persist collapse state in session storage and emit a `pui:sidebar-collapsed` event when the host needs to react.

## Extension and change rules

When extending PUI:

- Preserve semantic elements, roles, relationships, and keyboard behavior before changing presentation.
- Treat hook names, stable IDs, `data-*` markers, native input events, and custom PUI events as versioned contracts.
- Keep business decisions in the host application; accept values and events rather than introducing application policy into a primitive.
- Prefer native HTML behavior when it satisfies the interaction, as with Accordion.
- Keep browser-only state local to hooks unless the host explicitly needs it in LiveView state.
- If a component has both styled and unstyled paths, make the semantic contract identical unless the API explicitly documents a deliberate difference.
- Add deterministic rendered-markup tests for server contracts and browser-level coverage for hook behavior when the behavior cannot be proven from markup alone.

## Current boundary notes

- `use PUI` is the primary convenience surface for the main component families. `PUI.Flash` and `PUI.Loading` remain directly addressed modules rather than imports from the macro.
- Canonical component modules own one component family and are the preferred public namespace for new code. Shared helpers remain grouped when they support multiple families without owning a visual primitive.
- The current package contains both `PUI.Dropdown.menu_button/1` and a separate `PUI.MenuButton` module. The `use PUI` macro imports `PUI.Dropdown`; the latter is therefore the canonical documented menu-button path until the duplicate surface is intentionally consolidated.
- The package's public hook registry includes loading, popover, date picker, select, tabs, tooltip, flash group, sidebar, and chart hooks. A component that renders a hook declaration still requires the consuming application to merge PUI's exported hooks into its `LiveSocket`.
- The demo application is a consumer and executable documentation surface. It demonstrates the package, but it is not part of PUI's host-application domain boundary.
