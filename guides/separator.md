# PUI.Separator

`PUI.Separator` provides a small visual and semantic boundary between related
content.

## Usage

```heex
<.separator />
<.separator orientation="vertical" class="mx-2 h-5" />
```

Separators are decorative by default. For a meaningful structural boundary,
set `decorative={false}` and provide an accessible label where appropriate:

```heex
<.separator decorative={false} aria-label="Profile sections" />
```

## Attributes

| Attribute | Default | Description |
|-----------|---------|-------------|
| `orientation` | `"horizontal"` | `"horizontal"` or `"vertical"` |
| `decorative` | `true` | Whether assistive technology should ignore it |
| `class` | `""` | Additional utility classes |
| `rest` | — | Global HTML attributes |
