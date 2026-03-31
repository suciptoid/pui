%{
  title: "Progress & Badges",
  description: "Progress bars for completion status and badges for labels and counts.",
  group: "Data Display",
  order: 0,
  icon: "hero-chart-bar"
}
---

PUI includes a progress bar component for showing completion status and a badge component for labeling and categorizing content.

## Import

```elixir
use PUI
# or
import PUI.Components
```

## Progress Bar

Display progress with configurable min, max, and value:

```heex
<.progress value={45} />
```

### Custom Range

```heex
<.progress min={0} max={200} value={150} />
```

### Styled

```heex
<.progress value={75} class="h-3" />
<.progress value={30} class="h-1" />
```

### Dynamic Progress

Update progress in real-time with LiveView assigns:

```heex
<.progress value={@upload_progress} />
```

```elixir
def handle_info({:progress, value}, socket) do
  {:noreply, assign(socket, upload_progress: value)}
end
```

<AppWeb.DocsDemo.progress_badges_demo progress_value={@progress_value} />

## Badge

Badges are small labels for categorization and counts:

```heex
<.badge>Default</.badge>
<.badge variant="secondary">Secondary</.badge>
<.badge variant="destructive">Error</.badge>
<.badge variant="outline">Outline</.badge>
```

### Common Use Cases

```heex
<!-- Status indicator -->
<.badge variant="secondary">Active</.badge>

<!-- Count badge -->
<.badge>3 new</.badge>

<!-- In a list -->
<div class="flex items-center gap-2">
  <span>Notifications</span>
  <.badge variant="destructive">5</.badge>
</div>
```

## API Reference

### Progress Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `min` | `float` | `0.0` | Minimum value |
| `max` | `float` | `100.0` | Maximum value |
| `value` | `float` | `0.0` | Current value |
| `class` | `string` | `""` | Additional CSS classes |

### Badge Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `string` | `"default"` | Style: `"default"`, `"secondary"`, `"destructive"`, `"outline"` |
| `class` | `string` | `""` | Additional CSS classes |

### Badge Slots

| Name | Required | Description |
|------|----------|-------------|
| `inner_block` | ✓ | Badge content text |
