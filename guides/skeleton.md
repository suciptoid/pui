# PUI.Skeleton

`PUI.Skeleton` renders an animated placeholder while the host application is
waiting for content.

## Usage

```heex
<div class="space-y-3">
  <.skeleton class="h-4 w-48" />
  <.skeleton class="h-4 w-72" />
  <.skeleton class="h-24 w-full rounded-xl" />
</div>
```

Skeleton is presentation-only. Render it from the server-owned loading state
and choose dimensions that reserve the same space as the eventual content.

It is marked `aria-hidden="true"` by default because it has no meaningful
content. Add a separate live status or label if the loading state itself needs
to be announced.
