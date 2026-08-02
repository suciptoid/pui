# ADR 0006: Bounded v1 catalog expansion

## Status

Accepted

## Context

PUI follows the visual language and broad catalog direction of shadcn while
serving Phoenix LiveView applications. The existing library already covers
forms, overlays, navigation menus, tables, charts, date pickers, feedback, and
application layouts. A complete shadcn parity effort would make the v1 date and
API surface open-ended.

## Decision

Before v1, PUI adds six compositional primitives:

- Breadcrumb
- Separator
- Empty
- Skeleton
- Pagination
- Avatar

These components are server-rendered, have no new JavaScript hooks, and keep
routing, data loading, and application-owned content in the host application.
They provide styled defaults and explicit customization through slots, classes,
global attributes, and host-controlled link attributes.

Command, Combobox, standalone Calendar, Drawer/Sheet, Slider, Toggle Group,
and other state-heavy families remain post-v1 work. Existing `PUI.Select` and
`PUI.DatePicker` remain the canonical selection primitives for v1.

## Consequences

- The v1 catalog is useful for common application shells and data screens
  without promising broad component parity.
- New components can stabilize before the public API is frozen.
- Future component additions must either replace an existing overlapping
  primitive or be explicitly scoped as post-v1 work.
