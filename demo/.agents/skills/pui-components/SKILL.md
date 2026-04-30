---
name: pui-components
description: Implement UI using PUI components correctly in Phoenix LiveView apps and resolve API uncertainty by reading live module docs from the host project. Use when adding or editing PUI components, deciding attrs/slots/variants, or troubleshooting component usage.
---

# PUI Components

Follow this workflow for any task involving a PUI component.

## 1. Read the Exact Module Docs First

From the host app root, run:

```bash
mix run -e "require IEx.Helpers; IEx.Helpers.h(PUI.Dialog)"
```

Swap `PUI.Dialog` for the component being implemented (`PUI.Button`, `PUI.Input`, `PUI.Layout`, etc.).

Collect:

- Required attrs and slots
- Supported variants/values
- Any required `phx-hook` or JS behavior

## 2. Verify Imports and Calling Context

- Ensure the module has `use PUI` or explicit imports.
- Confirm the template context is HEEx (`~H`) and attributes are valid in that context.

## 3. Implement Minimal, Doc-Accurate Markup

- Prefer direct PUI component usage over local wrapper re-implementations.
- Pass only documented attrs first, then add custom classes if needed.
- For form fields, pass a proper `field` when available; otherwise pass explicit values.

## 4. Check Cross-Surface Reuse

If the component appears in shared partials or layouts, update all relevant surfaces (new, edit, modal, and route-level pages) to avoid inconsistent behavior.

## 5. Validate Quickly

Run:

```bash
mix compile
mix test
```

If behavior still looks wrong, inspect rendered markup and compare it with component docs again before adding workaround JS.

## 6. Troubleshooting Pattern

When a component appears but does not behave correctly:

1. Re-run `IEx.Helpers.h/1` for that module.
2. Verify required attrs and `:global` passthrough values.
3. Check for stale local wrappers overriding behavior.
4. Check whether headless variants (`variant=\"unstyled\"`) require explicit styling/visibility classes.

## References

- Read [`references/doc-command-cheatsheet.md`](references/doc-command-cheatsheet.md) for common module doc commands.
- Read [`references/component-usage-patterns.md`](references/component-usage-patterns.md) for implementation patterns.
