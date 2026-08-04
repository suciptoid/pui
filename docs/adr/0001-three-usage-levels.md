---
status: superseded
superseded_by: 0007-primitive-modules-replace-unstyled-variants
---

# Expose styled, unstyled, and low-level usage levels

PUI exposes the same component vocabulary as styled defaults, unstyled/headless primitives, and direct browser hooks. This preserves a ready-to-use path for ordinary LiveView screens, a semantic-and-behavior path for applications with their own visual system, and a low-level escape hatch for custom composition; the trade-off is that the hook and markup contracts must remain stable across all three levels.

Superseded by ADR 0007: the three levels remain, but the middle level moved from a `variant="unstyled"` branch inside each styled component to separate `PUI.<Family>.Primitive` modules.
