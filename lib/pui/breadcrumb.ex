defmodule PUI.Breadcrumb do
  @moduledoc """
  Accessible breadcrumb navigation primitives.

  Breadcrumbs describe the current location without owning routing. Links accept
  normal Phoenix `href`, `navigate`, and `patch` attributes, so the host
  application controls navigation and URL generation.

  ## Example

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

  ## Components

  | Component | Attributes | Description |
  |-----------|------------|-------------|
  | `breadcrumb/1` | `aria_label`, `class`, global attributes | Navigation landmark |
  | `breadcrumb_list/1` | `class` | Ordered breadcrumb list |
  | `breadcrumb_item/1` | `class` | One breadcrumb item |
  | `breadcrumb_link/1` | `class`, `href`, `navigate`, `patch` | Navigable ancestor |
  | `breadcrumb_page/1` | `class` | Current page with `aria-current` |
  | `breadcrumb_separator/1` | `class` | Customizable separator |
  | `breadcrumb_ellipsis/1` | `class` | Collapsed breadcrumb indicator |

  Application-specific separators can be supplied through the separator's
  `inner_block` slot. The default uses the provider-agnostic `:chevron_right`
  icon token.
  """

  use Phoenix.Component

  attr :aria_label, :string, default: "Breadcrumb"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def breadcrumb(assigns) do
    ~H"""
    <nav aria-label={@aria_label} class={["not-prose", @class]} {@rest}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def breadcrumb_list(assigns) do
    ~H"""
    <ol
      class={[
        "text-muted-foreground m-0 flex list-none flex-wrap items-center gap-1.5 p-0 text-sm break-words sm:gap-2.5",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ol>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def breadcrumb_item(assigns) do
    ~H"""
    <li class={[@class]} {@rest}>
      {render_slot(@inner_block)}
    </li>
    """
  end

  attr :class, :string, default: ""

  attr :rest, :global,
    include: ~w(href navigate patch replace method target rel download hreflang referrerpolicy)

  slot :inner_block, required: true

  def breadcrumb_link(assigns) do
    ~H"""
    <.link
      class={[
        "hover:text-foreground no-underline transition-colors",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  attr :class, :string, default: "font-normal text-foreground"
  attr :rest, :global
  slot :inner_block, required: true

  def breadcrumb_page(assigns) do
    ~H"""
    <span aria-current="page" class={[@class]} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  attr :class, :string, default: "[&>svg]:size-3.5"
  attr :rest, :global
  slot :inner_block

  def breadcrumb_separator(assigns) do
    ~H"""
    <li role="presentation" aria-hidden="true" class={[@class]} {@rest}>
      <%= if @inner_block == [] do %>
        <PUI.Icon.icon name={:chevron_right} />
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </li>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global

  def breadcrumb_ellipsis(assigns) do
    ~H"""
    <li role="presentation" aria-hidden="true" class={[@class]} {@rest}>
      <span aria-hidden="true">…</span>
      <span class="sr-only">More</span>
    </li>
    """
  end
end
