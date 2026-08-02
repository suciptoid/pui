# PUI.Empty

`PUI.Empty` is a composable empty state for collections, search results, and
first-use screens.

## Usage

```heex
<.empty>
  <:icon><PUI.Icon.icon name={:search} class="size-6" /></:icon>
  <:title>No projects found</:title>
  <:description>Try a different search or create a new project.</:description>
  <:actions>
    <.button>Create project</.button>
  </:actions>
</.empty>
```

The title is required. Description, icon, actions, and additional content are
optional slots owned by the application.

## Unstyled usage

Use `variant="unstyled"` when PUI should provide the semantic structure but
your design system owns the presentation:

```heex
<.empty variant="unstyled" class="gap-3">
  <:title>No notifications</:title>
  <:description>You are all caught up.</:description>
</.empty>
```

Application-owned icons should be passed through the icon slot. PUI does not
assume an icon library for empty-state content.
