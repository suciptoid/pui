---
status: accepted
---

# Keep icon intent independent from icon libraries

PUI uses a small semantic icon-token vocabulary for affordances rendered by its
own components and delegates their markup to one host-configured icon provider.
PUI ships a dependency-free Heroicons CSS-class provider by default, while
application-owned icons use slots so host applications can use Heroicons,
Lucide, Tabler, or custom SVG without changing PUI's component APIs. This keeps
the ready-to-use Phoenix path intact without making PUI responsible for an icon
library or for the host application's complete icon catalog.
