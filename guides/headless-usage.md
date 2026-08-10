# Interactive Primitives

PUI is styled-first. Use the normal components for the PUI visual system and
import a family's `.Primitive` module only when an application owns the markup
and CSS for a hook-managed interaction.

```elixir
import PUI.Select.Primitive

<.root id="assignee" class="relative" search_event="search_assignees">
  <.input id="assignee-input" name="assignee" />
  <.trigger id="assignee-trigger" listbox_id="assignee-listbox" class="my-trigger">
    Choose an assignee
  </.trigger>
  <.content id="assignee-listbox" trigger_id="assignee-trigger" class="my-menu">
    <.search id="assignee-search" listbox_id="assignee-listbox" />
    <.item value="ada" class="my-option data-[active=true]:bg-accent">Ada</.item>
  </.content>
</.root>
```

When `search_event` is present, the hook sends a debounced query to the
owning LiveView. The handler should query its data source and assign the new
options; clearing the query sends an empty query and keeps the selected value.

Primitive modules retain IDs, ARIA attributes, LiveView JS commands, and hook
data contracts. They intentionally add no visual classes, icons, animation, or
layout. Use plain semantic HTML for custom buttons, alerts, cards, tables,
empty states, and native accordions.

Select arrow-key navigation records the current option as
`data-active="true"` while focus remains on the listbox. Style that attribute
on each item. Dropdown primitive items are buttons or links without layout
classes, so add `w-full` when they should fill the menu and style
`aria-selected` with the same surface used for hover.

Available primitive families are `Dialog`, `Popover`, `Dropdown`, `Tooltip`,
`Select`, `Tabs`, `DatePicker`, `Flash`, and `Layout.Sidebar`.
