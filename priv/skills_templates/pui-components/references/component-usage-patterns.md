# Component Usage Patterns

## Baseline Pattern

1. Read module docs with `IEx.Helpers.h/1`.
2. Add minimal markup with documented attrs and slots.
3. Compile and test.
4. Style incrementally.

## Forms

- Prefer passing a `Phoenix.HTML.FormField` to `field` attrs when supported.
- Only fall back to direct `name`/`value` usage when the component allows it.

## Headless Variants

- If using variants like `unstyled`, provide explicit visibility and spacing classes.
- Do not assume default styles in headless paths.
