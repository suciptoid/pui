%{
  title: "Tabs",
  description: "Accessible tabbed interfaces with shadcn-inspired styling, keyboard support, and server or client control.",
  group: "Data Display",
  order: 2,
  icon: "hero-rectangle-group"
}
---

The Tabs component provides accessible, theme-aware tabbed interfaces inspired by shadcn/ui. It renders correct WAI-ARIA roles on the server and can be enhanced with the built-in `PUI.Tabs` hook for keyboard navigation, roving focus, and client-side activation.

## Import

```elixir
use PUI
# or
import PUI.Tabs
```

## Basic Usage

Use `tabs/1` with `:trigger` and `:content` slots. Triggers and panels are matched by their shared `value`.

```heex
<.tabs id="account-tabs" default_value="account">
  <:trigger value="account">Account</:trigger>
  <:trigger value="password">Password</:trigger>

  <:content value="account">
    Make changes to your account here.
  </:content>

  <:content value="password">
    Change your password here.
  </:content>
</.tabs>
```

<AppWeb.DocsDemo.tabs_client_demo />

## Client-Controlled Tabs

By default, tabs are client-controlled and use manual activation. The selected tab is initialized from `default_value`, then the `PUI.Tabs` hook updates the active trigger and panel in the browser when the user clicks a tab or presses `Space` / `Enter`.

```heex
<.tabs id="dashboard-tabs" default_value="overview">
  <:trigger value="overview">Overview</:trigger>
  <:trigger value="analytics">Analytics</:trigger>
  <:trigger value="reports">Reports</:trigger>

  <:content value="overview">Overview metrics…</:content>
  <:content value="analytics">Analytics metrics…</:content>
  <:content value="reports">Reports list…</:content>
</.tabs>
```

The client mode supports:

- `ArrowLeft` and `ArrowRight` for horizontal lists
- `ArrowUp` and `ArrowDown` for vertical lists
- `Home` and `End` to jump to the first or last enabled tab
- `Space` and `Enter` to activate the focused tab in manual mode
- automatic or manual activation modes

## Server-Controlled Tabs

Set `client_controlled={false}` and drive the active tab with the `value` assign when you want LiveView or a dead view to own selection state.

```heex
<.tabs id="settings-tabs" value={@active_tab} client_controlled={false} variant="line">
  <:trigger value="overview" phx-click="select_tab" phx-value-tab="overview">
    Overview
  </:trigger>
  <:trigger value="billing" phx-click="select_tab" phx-value-tab="billing">
    Billing
  </:trigger>

  <:content value="overview">Overview content…</:content>
  <:content value="billing">Billing content…</:content>
</.tabs>
```

<AppWeb.DocsDemo.tabs_server_demo active_tab={@active_tab} />

## Vertical Tabs

Use `orientation="vertical"` for settings pages, sidebars, and management consoles.

```heex
<.tabs id="preferences-tabs" default_value="notifications" orientation="vertical">
  <:trigger value="account">Account</:trigger>
  <:trigger value="notifications">Notifications</:trigger>
  <:trigger value="security">Security</:trigger>

  <:content value="account">Account settings…</:content>
  <:content value="notifications">Notification settings…</:content>
  <:content value="security">Security settings…</:content>
</.tabs>
```

<AppWeb.DocsDemo.tabs_vertical_demo />

## Full Demo

The full demo page below combines client-controlled, server-controlled, and vertical examples.

<AppWeb.DocsDemo.tabs_demo active_tab={@active_tab} />

## Accessibility

PUI Tabs follow the WAI-ARIA tabs pattern:

- `role="tablist"` on the trigger list
- `role="tab"` on each trigger
- `role="tabpanel"` on each panel
- `aria-selected`, `aria-controls`, and `aria-labelledby` are wired automatically
- disabled tabs are skipped during keyboard navigation

PUI defaults to manual activation so focus can move without changing the selected panel until the user presses `Enter` or `Space`. Set `activation_mode="automatic"` if you want selection to follow focus.

## Styling Variants

The default styles use the same theme tokens as the rest of PUI and follow shadcn-inspired spacing and state treatment.

```heex
<.tabs id="variant-tabs" default_value="overview" variant="line">
  <:trigger value="overview">Overview</:trigger>
  <:trigger value="analytics">Analytics</:trigger>
  <:content value="overview">Overview content</:content>
  <:content value="analytics">Analytics content</:content>
</.tabs>
```

Use `variant="unstyled"` when you want to keep the semantics and hook behavior but supply all presentation classes yourself.

## API Reference

### `tabs/1` Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `string` | generated | Unique base id for triggers and panels |
| `value` | `string` | `nil` | Active value when the server controls selection |
| `default_value` | `string` | first enabled trigger | Initial active tab for client-controlled mode |
| `orientation` | `string` | `"horizontal"` | `"horizontal"` or `"vertical"` |
| `activation_mode` | `string` | `"manual"` | `"automatic"` or `"manual"` |
| `client_controlled` | `boolean` | `true` | Whether the browser hook updates selection state |
| `variant` | `string` | `"default"` | `"default"`, `"line"`, or `"unstyled"` |
| `class` | `string` | `""` | Additional root classes |
| `list_class` | `string` | `""` | Additional tab list classes |
| `panels_class` | `string` | `""` | Additional panel wrapper classes |

### `:trigger` Slot Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `string` | **required** | Tab value matched to a panel |
| `id` | `string` | generated | Custom trigger id |
| `class` | `string` | `""` | Additional trigger classes |
| `disabled` | `boolean` | `false` | Disables the trigger |
| `phx-click` | `any` | `nil` | Optional server event handler |
| `phx-target` | `any` | `nil` | Optional LiveView target |
| `phx-value-tab` | `string` | trigger value | Value sent with `phx-click` |

### `:content` Slot Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `string` | **required** | Panel value matched to a trigger |
| `id` | `string` | generated | Custom panel id |
| `class` | `string` | `""` | Additional panel classes |
