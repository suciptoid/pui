# Doc Command Cheatsheet

Run module docs from the host project root:

```bash
mix run -e "require IEx.Helpers; IEx.Helpers.h(PUI.Dialog)"
mix run -e "require IEx.Helpers; IEx.Helpers.h(PUI.Layout)"
mix run -e "require IEx.Helpers; IEx.Helpers.h(PUI.Input)"
```

Use this before editing component usage so attrs, slots, and variants match the shipped API.
