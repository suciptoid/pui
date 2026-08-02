%{
  title: "Breadcrumb",
  description: "Accessible hierarchical navigation with host-controlled links.",
  group: "Layout",
  order: 2,
  icon: "hero-arrows-right-left"
}
---

`PUI.Breadcrumb` describes the current location without owning routing. Use
Phoenix `href`, `navigate`, or `patch` attributes for each ancestor link.

<AppWeb.DocsDemo.breadcrumb_demo />

## API

| Component | Purpose |
|-----------|---------|
| `breadcrumb/1` | Navigation landmark |
| `breadcrumb_list/1` | Ordered breadcrumb list |
| `breadcrumb_item/1` | One item in the path |
| `breadcrumb_link/1` | Navigable ancestor |
| `breadcrumb_page/1` | Current page with `aria-current` |
| `breadcrumb_separator/1` | Provider-agnostic or custom separator |
| `breadcrumb_ellipsis/1` | Collapsed path indicator |
