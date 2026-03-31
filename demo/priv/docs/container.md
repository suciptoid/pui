%{
  title: "Container",
  description: "Layout containers including Card and Header for structuring application UI.",
  group: "Layout",
  order: 0,
  icon: "hero-view-columns"
}
---

PUI's Container module provides structural components for organizing your application's content. The Card component is the primary layout primitive, offering a flexible structure with header, title, description, content, action, and footer sections.

## Import

```elixir
use PUI
# or
import PUI.Container
```

## Card

The Card is a versatile container with multiple sub-components for structured content:

```heex
<.card>
  <.card_header>
    <.card_title>Card Title</.card_title>
    <.card_description>Card description goes here.</.card_description>
  </.card_header>
  <.card_content>
    <p>Main content of the card.</p>
  </.card_content>
  <.card_footer>
    <.button variant="outline">Cancel</.button>
    <.button>Save</.button>
  </.card_footer>
</.card>
```

<AppWeb.DocsDemo.container_card_demo />

## Card with Actions

Add action buttons to the card header:

```heex
<.card>
  <.card_header>
    <.card_title>Team Members</.card_title>
    <.card_description>Manage your team.</.card_description>
    <.card_action>
      <.button size="sm">
        <.icon name="hero-plus" class="size-4 mr-1" /> Add Member
      </.button>
    </.card_action>
  </.card_header>
  <.card_content>
    <!-- Team member list -->
  </.card_content>
</.card>
```

<AppWeb.DocsDemo.container_card_action_demo />

## Simple Card

Cards work with just content for simple use cases:

```heex
<.card>
  <.card_content>
    <p>Simple card with just content.</p>
  </.card_content>
</.card>
```

## Page Header

The `header` component provides a consistent page-level heading with optional subtitle and actions:

```heex
<.header>
  Dashboard
  <:subtitle>Welcome back! Here's what's happening.</:subtitle>
  <:actions>
    <.button>New Report</.button>
  </:actions>
</.header>
```

## API Reference

### Card Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `string` | `""` | Additional CSS classes |

### Card Sub-Components

| Component | Description |
|-----------|-------------|
| `card_header` | Top section containing title, description, and actions |
| `card_title` | Main heading text (supports `class`) |
| `card_description` | Subtitle/description text |
| `card_action` | Right-aligned action buttons in header |
| `card_content` | Main content area |
| `card_footer` | Bottom section (supports `class`) |

### Header Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Header title text |
| `subtitle` | — | Description text below title |
| `actions` | — | Action buttons on the right |
