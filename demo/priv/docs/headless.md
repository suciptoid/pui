%{
  title: "Interactive Primitives",
  description: "Compose zero-style PUI primitives when your application owns interactive markup.",
  group: "Getting Started",
  order: 1,
  icon: "hero-adjustments-horizontal"
}

---

# Interactive primitives

PUI is styled by default. For a hook-managed interaction with application-owned
markup and classes, import that family's `.Primitive` module. Primitives keep
the ID, ARIA, state, and JavaScript hook contract while contributing no visual
classes.

```heex
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

<AppWeb.DocsDemo.headless_demo />

## Dropdown primitive

```heex
<PUI.Dropdown.Primitive.root id="account-menu" placement="bottom-start">
  <PUI.Dropdown.Primitive.trigger id="account-menu-trigger" controls="account-menu-content">
    Account
  </PUI.Dropdown.Primitive.trigger>
  <PUI.Dropdown.Primitive.content id="account-menu-content" class="aria-hidden:hidden block my-menu">
    <PUI.Dropdown.Primitive.item>Profile</PUI.Dropdown.Primitive.item>
    <PUI.Dropdown.Primitive.item>Settings</PUI.Dropdown.Primitive.item>
  </PUI.Dropdown.Primitive.content>
</PUI.Dropdown.Primitive.root>
```

## Dialog primitive

```heex
<PUI.Dialog.Primitive.root :let={actions} id="delete-project">
  <PUI.Dialog.Primitive.backdrop id="delete-project-backdrop" class="fixed inset-0 bg-black/50" />
  <PUI.Dialog.Primitive.content id="delete-project-content" class="fixed inset-0 m-auto h-fit w-96 rounded-xl bg-white p-6 shadow-xl">
    <h2>Delete project?</h2>
    <button type="button" phx-click={actions.hide}>Cancel</button>
  </PUI.Dialog.Primitive.content>
</PUI.Dialog.Primitive.root>
```

Use normal HTML for custom static controls such as buttons, alerts, cards,
tables, empty states, and native accordions.
