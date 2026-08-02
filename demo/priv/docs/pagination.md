%{
  title: "Pagination",
  description: "Accessible host-controlled page navigation.",
  group: "Data Display",
  order: 5,
  icon: "hero-queue-list"
}
---

`PUI.Pagination` renders links but does not load data or own URL state. The
host supplies a `page_url` callback and chooses `href`, `navigate`, or `patch`.

<AppWeb.DocsDemo.pagination_demo />

The previous, next, and page slots can replace the default labels and semantic
chevrons.
