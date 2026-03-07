<p align="center">
  <img src="demo/assets/maui-hook.png" alt="MAUI Logo" width="200"/>
</p>

# MAUI Components

## Headless Components

Maui supports three usage levels:

**Level 1: Low-level Hooks** - Direct Floating UI access
```elixir
<.popover_base phx-hook="Maui.Popover">
  <.button>Trigger</.button>
  <:popup class="custom">Content</:popup>
</.popover_base>
```

**Level 2: Unstyled Components** - Behavior without styles
```elixir
<.menu_button variant="unstyled" class="my-btn">
  Open
  <:item class="my-item">Profile</:item>
</.menu_button>
```

**Level 3: Styled Components** - Ready-to-use defaults
```elixir
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>
```

See [Headless Usage Guide](guides/headless-usage.md) for details.
