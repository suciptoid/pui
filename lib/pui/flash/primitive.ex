defmodule PUI.Flash.Primitive do
  @moduledoc """
  Zero-style toast container and toast parts.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :position, :string, default: "bottom-right"
  attr :rest, :global
  slot :inner_block, required: true

  def container(assigns),
    do: ~H|<div id={@id} data-position={@position} phx-hook="PUI.FlashGroup" {@rest}>
  {render_slot(@inner_block)}
</div>|

  attr :id, :string, required: true
  attr :position, :string, default: "bottom-right"
  attr :duration, :integer, default: 5000
  attr :rest, :global
  slot :inner_block, required: true
  def toast(assigns), do: ~H|<div
  id={@id}
  role="alert"
  aria-hidden="true"
  data-flash-id={@id}
  data-position={@position}
  data-duration={@duration}
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :rest, :global
  slot :inner_block, required: true

  def close(assigns),
    do: ~H|<button type="button" data-close {@rest}>{render_slot(@inner_block)}</button>|
end
