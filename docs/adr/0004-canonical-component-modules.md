---
status: accepted
---

# Give each public component family a canonical module

PUI will prefer one canonical public module per component family, such as
`PUI.Badge`, `PUI.Progress`, and `PUI.Card`. Shared helpers may remain grouped
when they support several families without owning a standalone visual
primitive. Existing grouped APIs remain as deprecated compatibility wrappers
when moving ownership would otherwise break consumers.

This makes the catalog discoverable and aligns the module structure with the
styled component vocabulary. The trade-off is a temporary duplicate surface:
new code has a clear canonical path while existing applications receive
deprecation guidance instead of an immediate breaking change.
