# Changelog

## Next

- Allow each flash trigger to override the configured group position.
- Add per-position stacked layouts with hover/focus expansion and message limits.
- Fix collapsed stack cards so their indicators peek behind the front message.
- Cap collapsed stack indicators at three while keeping the full stack expandable.
- Make expanded flash layout the default; opt into stacking with `stacked`.
- Fix LiveComponent dismissal targeting, timeout wiring, and flash accessibility labels.

## 1.0.0 - 2026-08-02

PUI v1 provides a stable Phoenix LiveView component catalog with styled and
customizable composition paths.

- Added Breadcrumb, Separator, Empty, Skeleton, Pagination, and Avatar.
- Added provider-agnostic semantic icons with Heroicons as the default adapter.
- Added canonical Card, Badge, Progress, Table, and Layout APIs.
- Kept deprecated grouped component entry points available for v1 compatibility.
- Added HexDocs guides, demo coverage, accessibility assertions, and release checks.
