%{
  title: "Card",
  description: "Composable surfaces for grouping related content.",
  group: "Layout",
  order: 0,
  icon: "hero-square-2-stack"
}
---

`PUI.Card` provides a composable container with header, title, description,
action, content, and footer primitives.

## Import

```elixir
use PUI
# or
import PUI.Card
```

## Usage

```heex
<.card>
  <.card_header>
    <.card_title>Team Members</.card_title>
    <.card_description>Manage your team.</.card_description>
    <.card_action>
      <.button size="sm">Add member</.button>
    </.card_action>
  </.card_header>
  <.card_content>Member list.</.card_content>
</.card>
```

<AppWeb.DocsDemo.card_demo />

## API Reference

| Component | Attributes | Description |
|-----------|------------|-------------|
| `card/1` | `class`, global HTML attributes | Main card container |
| `card_header/1` | — | Header layout |
| `card_title/1` | `class` | Card title |
| `card_description/1` | `class` | Supporting description |
| `card_action/1` | — | Header action |
| `card_content/1` | — | Main content |
| `card_footer/1` | `class` | Footer area |
