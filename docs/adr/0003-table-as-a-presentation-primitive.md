# Keep tables presentation-only

PUI.Table will provide styled and unstyled table structure, LiveView stream rendering, row identity, and composable column/action slots, while host applications retain ownership of sorting, filtering, pagination, authorization, and data loading. This keeps the component reusable across PUI’s dogfood applications and avoids coupling a visual primitive to one application’s query or navigation model.

## Consequences

- The table can be used with ordinary lists and `Phoenix.LiveView.LiveStream` values.
- Consumers must compose query controls and pagination outside the table.
- The public API includes explicit part-level classes so applications can customize the recipe without replacing the semantic structure.
