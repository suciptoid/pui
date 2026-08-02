# PUI.Progress

`PUI.Progress` renders an accessible progress bar for completion and loading
states. The host LiveView owns the value and can update it through assigns.

## Usage

```heex
<.progress value={42} label="Upload progress" />
<.progress value={3} min={0} max={10} value_text="3 of 10 items" />
<.progress value={75} class="h-3" />
```

## LiveView updates

```elixir
def handle_info({:upload_progress, value}, socket) do
  {:noreply, assign(socket, upload_progress: value)}
end
```

```heex
<.progress value={@upload_progress} label="Upload progress" />
```

## Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `min` | `float` | `0.0` | Minimum progress value |
| `max` | `float` | `100.0` | Maximum progress value |
| `value` | `float` | `0.0` | Current progress value |
| `label` | `string` | `nil` | Accessible label for the progressbar |
| `aria_labelledby` | `string` | `nil` | ID of an element labelling the progressbar |
| `value_text` | `string` | `nil` | Human-readable value announced by screen readers |
| `class` | `string` | `""` | Additional CSS classes |

The canonical module is `PUI.Progress`. Existing
`PUI.Components.progress/1` calls remain available as deprecated compatibility
wrappers.
