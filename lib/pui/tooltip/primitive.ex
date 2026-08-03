defmodule PUI.Tooltip.Primitive do
  @moduledoc """
  Zero-style tooltip parts backed by the PUI tooltip hook.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :placement, :string, default: "top"
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns),
    do: ~H|<div id={@id} data-placement={@placement} phx-hook="PUI.Tooltip" {@rest}>
  {render_slot(@inner_block)}
</div>|

  attr :id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def content(assigns),
    do:
      ~H|<div id={@id} role="tooltip" aria-hidden="true" {@rest}>{render_slot(@inner_block)}</div>|
end
