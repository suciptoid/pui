# PUI.Breadcrumb

`PUI.Breadcrumb` renders accessible navigation for hierarchical pages while
leaving URL generation and navigation mode to the host application.

## Usage

```heex
<.breadcrumb>
  <.breadcrumb_list>
    <.breadcrumb_item>
      <.breadcrumb_link navigate={~p"/projects"}>Projects</.breadcrumb_link>
    </.breadcrumb_item>
    <.breadcrumb_separator />
    <.breadcrumb_item>
      <.breadcrumb_page>Website refresh</.breadcrumb_page>
    </.breadcrumb_item>
  </.breadcrumb_list>
</.breadcrumb>
```

The current page renders `aria-current="page"`. Ancestor links accept the
normal Phoenix `href`, `navigate`, and `patch` attributes.

## Custom separator

```heex
<.breadcrumb_separator>
  <span class="text-muted-foreground">/</span>
</.breadcrumb_separator>
```

The default separator uses the `:chevron_right` semantic icon token and is
therefore provider-agnostic.

## Collapsed paths

Use `breadcrumb_ellipsis/1` when a long path needs to hide intermediate items:

```heex
<.breadcrumb_ellipsis />
```

## Customization

Every primitive accepts `class`. The outer navigation and list/item primitives
also forward global HTML attributes, so applications can add test IDs and
additional accessibility metadata without changing the component markup.
