%{
  title: "Loading",
  description: "Loading indicator for page transitions and form submissions.",
  group: "Feedback",
  order: 2,
  icon: "hero-speaker-wave"
}
---

The Loading component provides a top progress bar that automatically appears during LiveView page transitions and form submissions. It provides visual feedback that something is happening.

## Import

```elixir
use PUI
# or
import PUI.Loading
```

## Basic Usage

Add the topbar to your root layout (typically in `root.html.heex`):

```heex
<PUI.Loading.topbar />
```

<AppWeb.DocsDemo.loading_topbar_demo />

The progress bar will automatically show during:
- LiveView navigation (page transitions)
- `phx-click` events while processing
- Form submissions

## Custom Styling

Override the default appearance with custom classes:

```heex
<PUI.Loading.topbar class="bg-orange-500! animate-pulse shadow-orange-500/20!" />
```

### Color Examples

```heex
<!-- Blue gradient -->
<PUI.Loading.topbar class="bg-blue-500!" />

<!-- Green -->
<PUI.Loading.topbar class="bg-green-500!" />

<!-- Custom with animation -->
<PUI.Loading.topbar class="bg-purple-500! animate-pulse" />
```

## Custom Delay

Control how long to wait before showing the bar (prevents flashing on fast loads):

```heex
<!-- Show immediately -->
<PUI.Loading.topbar delay={0} />

<!-- Wait 500ms before showing (default: 300ms) -->
<PUI.Loading.topbar delay={500} />
```

## API Reference

### Attributes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `delay` | `integer` | `300` | Milliseconds to wait before showing the bar |
| `class` | `string` | `""` | Additional CSS classes for custom styling |
