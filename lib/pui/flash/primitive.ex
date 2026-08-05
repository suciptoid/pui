defmodule PUI.Flash.Primitive do
  @moduledoc """
  Zero-style flash viewport and toast parts.

  The primitive exposes the same positioning, stacking, and timeout data
  contract as PUI.Flash, while leaving the visual treatment to the caller.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :position, :string, default: "bottom-right"
  attr :stacked, :boolean, default: false
  attr :timeout, :integer, default: 5000
  attr :live_component, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def container(assigns),
    do: ~H|<div
  id={@id}
  data-position={@position}
  data-stacked={to_string(@stacked)}
  data-flash-timeout={@timeout}
  data-live-component={to_string(@live_component)}
  phx-hook="PUI.FlashGroup"
  class="pointer-events-none fixed inset-0 z-[1000]"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :id, :string, required: true
  attr :position, :string, default: "bottom-right"
  attr :duration, :integer, default: 5000
  attr :timeout, :integer, default: nil
  attr :auto_dismiss, :boolean, default: true
  attr :rest, :global
  slot :inner_block, required: true
  def toast(assigns), do: ~H|<div
  id={@id}
  role="alert"
  aria-hidden="true"
  data-flash-id={@id}
  data-position={@position}
  data-duration={@duration}
  data-timeout={if is_nil(@timeout), do: @duration, else: @timeout}
  data-auto-dismiss={to_string(@auto_dismiss)}
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :rest, :global
  slot :inner_block, required: true

  def close(assigns),
    do: ~H|<button type="button" data-close {@rest}>{render_slot(@inner_block)}</button>|
end
