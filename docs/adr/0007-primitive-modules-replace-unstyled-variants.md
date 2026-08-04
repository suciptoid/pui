---
status: accepted
---

# Replace `variant="unstyled"` with per-family primitive modules

PUI removes the `"unstyled"` value from every component `variant` attribute and
exposes a `PUI.<Family>.Primitive` module for each family whose behavior is
managed by a browser hook: `Dialog`, `Popover`, `Dropdown`, `Tooltip`, `Select`,
`Tabs`, `DatePicker`, `Flash`, and `Layout.Sidebar`. Families with no
hook-managed behavior — button, alert, card, table, empty, accordion — get no
primitive module, because plain semantic HTML already serves that need.

This supersedes ADR 0001's framing of a single component vocabulary rendered at
three levels. A component that branched internally on `is_unstyled` carried two
markup contracts in one function, which made the styled path harder to read and
left the headless path with attributes it silently ignored. Separate modules
give each path its own attributes, its own tests, and an explicit import.

The trade-off is a breaking change for consumers of `variant="unstyled"` with no
compatibility shim: the styled components keep their existing names and
behavior, so a deprecated wrapper would have to guess which primitive
composition the consumer wanted. Callers migrate by importing the family's
`.Primitive` module and supplying their own markup, including the visibility
classes that the styled components previously provided.
