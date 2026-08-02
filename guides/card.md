# PUI.Card

`PUI.Card` provides composable surfaces for grouping related content.

## Usage

```heex
<.card>
  <.card_header>
    <.card_title>Profile</.card_title>
    <.card_description>Manage your account details.</.card_description>
    <.card_action>
      <.button size="sm">Edit</.button>
    </.card_action>
  </.card_header>
  <.card_content>Your profile information.</.card_content>
  <.card_footer>
    <.button>Save</.button>
  </.card_footer>
</.card>
```

## API

| Component | Attributes | Description |
|-----------|------------|-------------|
| `card/1` | `class`, global HTML attributes | Main card container |
| `card_header/1` | — | Header layout for title, description, and action |
| `card_title/1` | `class` | Card title |
| `card_description/1` | `class` | Supporting description |
| `card_action/1` | — | Right-aligned header action |
| `card_content/1` | — | Main content area |
| `card_footer/1` | `class` | Footer area |

All components accept an `inner_block` slot. Card is a presentation primitive;
the host application owns the meaning and behavior of its contents.

The canonical module is `PUI.Card`. Existing `PUI.Container.card*` calls remain
available as deprecated compatibility wrappers.
