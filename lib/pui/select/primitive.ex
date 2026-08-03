defmodule PUI.Select.Primitive do
  @moduledoc """
  Zero-style, hook-wired select parts.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :value, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns) do
    ~H|<div id={@id} data-value={@value} phx-hook="PUI.Select" {@rest}>{render_slot(@inner_block)}</div>|
  end

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    ~H|<input
  id={@id}
  data-pui="select-value"
  type="hidden"
  name={@name}
  value={@value}
  aria-hidden="true"
  {@rest}
/>|
  end

  attr :id, :string, required: true
  attr :listbox_id, :string, required: true
  attr :invalid, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def trigger(assigns) do
    ~H|<button
  id={@id}
  type="button"
  aria-haspopup="listbox"
  aria-expanded="false"
  aria-controls={@listbox_id}
  aria-invalid={if @invalid, do: "true"}
  {@rest}
>{render_slot(@inner_block)}</button>|
  end

  attr :placeholder, :string, default: "Select an item"
  attr :rest, :global
  slot :inner_block

  def value(assigns) do
    ~H|<span data-pui="selected-label" data-slot="select-value" data-placeholder={@placeholder} {@rest}>{render_slot(
  @inner_block,
  @placeholder
)}</span>|
  end

  attr :id, :string, required: true
  attr :trigger_id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def content(assigns) do
    ~H|<div
  id={@id}
  role="listbox"
  tabindex="-1"
  aria-labelledby={@trigger_id}
  aria-hidden="true"
  data-side="bottom"
  data-floating-strategy="absolute"
  data-reference-hidden="false"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|
  end

  attr :value, :string, required: true
  attr :id, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item(assigns) do
    ~H|<div id={@id} role="option" aria-selected="false" tabindex="-1" data-value={@value} {@rest}>
  {render_slot(@inner_block)}
</div>|
  end
end
