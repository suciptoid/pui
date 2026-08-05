# Changelog

## v1 Changes

PUI v1 consolidates the stable features delivered throughout the alpha and beta
releases into a styled-first Phoenix LiveView component catalog with explicit
primitive modules for application-owned markup.

### Component catalog

- Added Accordion, Alert, Avatar, Badge, Breadcrumb, Button, Button Group,
  Card, Container, Empty, Pagination, Progress, Separator, Skeleton, Table,
  and Layout components.
- Added field-aware Input controls for text inputs, textareas, checkboxes,
  radios, switches, labels, and validation feedback.
- Added searchable Select controls with custom items, empty-result states,
  keyboard navigation, hidden form inputs, and field integration.
- Added DatePicker and RangePicker components with constrained dates,
  selectable months, week-start configuration, footer slots, and validation
  feedback.
- Added Dialog, Dropdown, Popover, Tabs, and Tooltip interactions with focus,
  keyboard, positioning, dismissal, and LiveView lifecycle support.
- Added customizable application shells with Layout, Sidebar, submenu items,
  content headers, collapse state, and navigation support.

### Charts and icons

- Added a composable uPlot-backed Chart component with serializable configs,
  LiveView updates, extensible hooks, and BarChart, LineChart, and Sparkline
  helpers.
- Added provider-agnostic semantic icons with Heroicons as the default provider
  and support for application-configured icon providers.

### Flash and loading feedback

- Added Phoenix-compatible preset flash toasts, custom HEEx content, close
  controls, auto-dismiss timing, LiveComponent updates, and accessible labels.
- Added per-trigger flash placement overrides and independent stacks for each
  screen position.
- Added optional collapsed stacking with hover/focus expansion, safe hover
  areas, timer pausing, message limits, and up to three visible stack
  indicators.
- Added a LiveView loading topbar with configurable delay and styling.

### Composition and accessibility

- Replaced the former `variant="unstyled"` approach with explicit
  `PUI.<Family>.Primitive` modules for Dialog, Popover, Dropdown, Tooltip,
  Select, Tabs, DatePicker, Flash, and Sidebar interactions.
- Added semantic theme-token styling, slot-based customization, global
  attribute forwarding, and host-owned presentation paths.
- Improved ARIA relationships, labels, invalid states, keyboard behavior,
  focus restoration, dialog cancellation, menu semantics, and form error
  announcements across interactive components.
- Normalized canonical component module boundaries while retaining compatibility
  delegates where required for v1.

### Documentation and developer experience

- Added HexDocs guides, an interactive demo and documentation site, component
  API references, migration guidance, accessibility assertions, and release
  checks.
- Added installable PUI agent skills for component usage and migration.
