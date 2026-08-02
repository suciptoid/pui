defmodule PUI.Card do
  @moduledoc """
  Card primitives for grouping related content.

  The Card family is composed from a container and optional header, title,
  description, action, content, and footer sections.

  ## Examples

      <.card>
        <.card_header>
          <.card_title>Profile</.card_title>
          <.card_description>Manage your account details.</.card_description>
        </.card_header>
        <.card_content>Card content.</.card_content>
        <.card_footer>
          <.button>Save</.button>
        </.card_footer>
      </.card>

  ## Attributes

  | Component | Attributes |
  |-----------|------------|
  | `card/1` | `class`, global HTML attributes |
  | `card_title/1`, `card_description/1` | `class` |
  | `card_footer/1` | `class` |
  | `card_header/1`, `card_description/1`, `card_action/1`, `card_content/1` | none |

  ## Slots

  All Card family components accept an `inner_block` slot.
  """

  use Phoenix.Component

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  def card(assigns) do
    ~H"""
    <div
      class={[
        "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6 shadow-sm",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_header(assigns) do
    ~H"""
    <div class="@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  def card_title(assigns) do
    ~H"""
    <div class={["leading-none font-semibold", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  def card_description(assigns) do
    ~H"""
    <div class={["text-muted-foreground text-sm", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_action(assigns) do
    ~H"""
    <div class="col-start-2 row-span-2 row-start-1 self-start justify-self-end">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block

  def card_content(assigns) do
    ~H"""
    <div class="px-6">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block

  def card_footer(assigns) do
    ~H"""
    <div class={["flex items-center px-6 [.border-t]:pt-6", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
