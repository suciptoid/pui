# PUI UI Composition Context

PUI is the UI composition context for Phoenix LiveView applications. It provides reusable primitives for presentation, accessibility, interaction, and form feedback while leaving application business meaning and persistence to the host application.

## Toolkit Language

**PUI**:
The reusable UI toolkit and its shared vocabulary. PUI describes how an interface is composed and behaves, not what a host application's business concepts mean.
_Avoid_: application domain, business context

**Host application**:
The Phoenix LiveView application that supplies business meaning, server events, and application state to PUI components.
_Avoid_: client application, consumer domain

**Primitive**:
A small composable UI unit with a focused responsibility, such as a button, trigger, content region, item, field control, or layout shell.
_Avoid_: widget, page component

**Component family**:
A group of primitives that share one interaction or presentation concept, such as a trigger with its popup, or tabs with their panels.
_Avoid_: component bundle, module group

**Composition**:
Combining PUI primitives through attributes and slots to form an interface while keeping each primitive's semantics and interaction contract.
_Avoid_: nesting, assembly

**Canonical component module**:
A public PUI namespace whose primary responsibility is one component family and its composition primitives.
_Avoid_: utility module, catch-all component module

**Shared helper**:
A reusable function that supports multiple component families without defining a standalone visual primitive, such as form-error translation or icon rendering.
_Avoid_: component family, primitive

## Presentation Modes

**Styled component**:
A PUI primitive that supplies default visual treatment while still accepting consumer customization.
_Avoid_: default component, opinionated widget

**Unstyled component**:
A PUI primitive that keeps its structure, semantics, and supported behavior but omits PUI's default visual classes so the host application owns presentation.
_Avoid_: bare component, styleless widget

**Headless path**:
The PUI usage path where consumers keep PUI's markup and interaction semantics while controlling presentation themselves. It includes unstyled components and direct hook usage.
_Avoid_: custom component, CSS-only mode

**Low-level hook**:
A directly consumed browser behavior that expects the host application to provide the surrounding markup and the hook's required semantic and data attributes.
_Avoid_: JavaScript component, client component

**Semantic contract**:
The roles, states, relationships, focus behavior, and native elements that make a primitive understandable and operable to users and assistive technologies.
_Avoid_: accessibility metadata, ARIA config

## State and Interaction

**Server-owned state**:
State that must participate in LiveView rendering, form submission, validation, or application events, such as a selected form value or a dialog's server-controlled visibility.
_Avoid_: backend state, persistent state

**Browser-owned state**:
Ephemeral interaction state that belongs in the browser, such as focus, open animations, popup placement, keyboard position, and resize measurements.
_Avoid_: client state, frontend state

**Hook contract**:
The stable agreement between server-rendered markup and a PUI hook about identity, semantics, interaction state, and synchronization.
_Avoid_: DOM implementation, JavaScript API

**Synchronization**:
The deliberate movement of state across the LiveView/browser boundary through rendered state and interaction signals.
_Avoid_: two-way binding, DOM syncing

**Progressive enhancement**:
The practice of using native HTML behavior where it is sufficient, then adding PUI hooks or LiveView coordination only for richer interaction.
_Avoid_: JavaScript fallback, client-first rendering

## Form Language

**Field-backed control**:
A PUI form control bound to a host application's form field, from which it derives identity, submitted value, and validation state.
_Avoid_: bound input, model input

**Direct-value control**:
A PUI form control configured with explicit identity, value, and error attributes instead of a `Phoenix.HTML.FormField`.
_Avoid_: manual field, uncontrolled input

**Validation feedback**:
The error presentation associated with a form control after the host application's form state marks the field as used or supplies explicit errors.
_Avoid_: form error, validation state

## Feedback Language

**Feedback surface**:
A UI primitive that communicates status or progress without owning the business event that caused it, such as an alert, flash message, loading bar, progress indicator, or badge.
_Avoid_: notification system, status domain

**Flash message**:
A transient feedback message supplied by the host application and rendered by PUI, optionally streamed, auto-dismissed, updated, or manually dismissed.
_Avoid_: toast, notification

**Layout shell**:
The structural page frame around application content, including navigation, sidebar state, and content headers.
_Avoid_: dashboard, page layout

**Data table**:
A presentation surface that organizes a collection into labeled columns and rows while leaving data loading and row meaning to the host application.
_Avoid_: query table, grid controller
