%{
  title: "Progress",
  description: "Accessible progress bars for completion and loading states.",
  group: "Data Display",
  order: 1,
  icon: "hero-chart-bar"
}
---

`PUI.Progress` renders an accessible progressbar with configurable bounds and
labels.

## Import

```elixir
use PUI
# or
import PUI.Progress
```

## Usage

```heex
<.progress value={45} label="Upload progress" />
<.progress value={3} min={0} max={10} value_text="3 of 10 items" />
```

<AppWeb.DocsDemo.progress_demo progress_value={@progress_value} />

## API Reference

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `min` | `float` | `0.0` | Minimum progress value |
| `max` | `float` | `100.0` | Maximum progress value |
| `value` | `float` | `0.0` | Current progress value |
| `label` | `string` | `nil` | Accessible label |
| `aria_labelledby` | `string` | `nil` | ID of the labelling element |
| `value_text` | `string` | `nil` | Human-readable announced value |
| `class` | `string` | `""` | Additional CSS classes |
