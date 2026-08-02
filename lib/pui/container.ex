defmodule PUI.Container do
  @moduledoc """
  Structural helpers for organizing page content.

  `PUI.Container` provides a page-level header and Heroicon wrapper. The Card
  family now lives in `PUI.Card`; the qualified Card functions remain here as
  deprecated compatibility wrappers for existing consumers.

  ## Components

  | Component | Description |
  |-----------|-------------|
  | `header/1` | Page heading with optional subtitle and actions |
  | `icon/1` | Heroicon component |
  """

  use Phoenix.Component

  @deprecated "Use PUI.Card.card/1 instead."
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true
  def card(assigns), do: PUI.Card.card(assigns)

  @deprecated "Use PUI.Card.card_header/1 instead."
  slot :inner_block
  def card_header(assigns), do: PUI.Card.card_header(assigns)

  @deprecated "Use PUI.Card.card_title/1 instead."
  attr :class, :string, default: ""
  slot :inner_block
  def card_title(assigns), do: PUI.Card.card_title(assigns)

  @deprecated "Use PUI.Card.card_description/1 instead."
  attr :class, :string, default: ""
  slot :inner_block
  def card_description(assigns), do: PUI.Card.card_description(assigns)

  @deprecated "Use PUI.Card.card_action/1 instead."
  slot :inner_block
  def card_action(assigns), do: PUI.Card.card_action(assigns)

  @deprecated "Use PUI.Card.card_content/1 instead."
  slot :inner_block
  def card_content(assigns), do: PUI.Card.card_content(assigns)

  @deprecated "Use PUI.Card.card_footer/1 instead."
  attr :class, :string, default: ""
  slot :inner_block
  def card_footer(assigns), do: PUI.Card.card_footer(assigns)

  @doc """
  Renders a page-level heading with an optional subtitle and actions.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4"]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com) by name.

  Icons use Heroicons' outline, solid, or mini naming conventions. Add a
  suffix such as `-solid` or `-mini` to select another style.
  """
  attr :name, :string, required: true
  attr :class, :string, default: "size-4"
  attr :rest, :global

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} {@rest} />
    """
  end
end
