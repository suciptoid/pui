%{
  title: "Separator",
  description: "Visual and semantic boundaries for related content.",
  group: "Layout",
  order: 3,
  icon: "hero-minus"
}
---

Use `PUI.Separator` for horizontal or vertical boundaries. It is decorative by
default and can opt into separator semantics with `decorative={false}`.

<AppWeb.DocsDemo.separator_demo />

```heex
<.separator />
<.separator orientation="vertical" class="mx-2 h-5" />
```
