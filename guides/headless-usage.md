# Interactive Primitives

PUI is styled-first. Use the normal components for the PUI visual system and
import a family's `.Primitive` module only when an application owns the markup
and CSS for a hook-managed interaction.

```elixir
import PUI.Select.Primitive

<.root id="assignee" class="relative">
  <.trigger id="assignee-trigger" listbox_id="assignee-listbox" class="my-trigger">
    Choose an assignee
  </.trigger>
  <.content id="assignee-listbox" trigger_id="assignee-trigger" class="my-menu">
    <.item value="ada" class="my-option">Ada</.item>
  </.content>
</.root>
```

Primitive modules retain IDs, ARIA attributes, LiveView JS commands, and hook
data contracts. They intentionally add no visual classes, icons, animation, or
layout. Use plain semantic HTML for custom buttons, alerts, cards, tables,
empty states, and native accordions.

Available primitive families are `Dialog`, `Popover`, `Dropdown`, `Tooltip`,
`Select`, `Tabs`, `DatePicker`, `Flash`, and `Layout.Sidebar`.
