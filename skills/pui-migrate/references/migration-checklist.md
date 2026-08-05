# Migration Checklist

1. Add `{:pui, "~> 1.0.0-alpha"}` and run `mix deps.get`.
2. Enable `use PUI` in `*_web.ex` and/or target LiveViews.
3. Replace generated component calls with PUI modules.
4. Move dashboard shell markup to `PUI.Layout` primitives.
5. Remove daisyUI-only classes and dead wrapper helpers.
6. Verify flash/loading wiring using `PUI.Flash.flash_group` and `PUI.Loading.topbar`.
7. Run `mix compile`, `mix test`, and `mix format`.
