# PUI.Avatar

`PUI.Avatar` renders a circular image with a host-controlled fallback.

## Usage

```heex
<.avatar src={@user.avatar_url} alt={@user.name} fallback_text="SC" />
```

When `src` is absent, the fallback renders instead:

```heex
<.avatar alt="Team" size="lg">
  <:fallback>TM</:fallback>
</.avatar>
```

Available sizes are `"sm"`, `"default"`, and `"lg"`. Use `class` for custom
dimensions or presentation. PUI does not add a JavaScript image-error handler;
applications that need fallback behavior after a remote image fails can add
their own global attributes or hook.
