defmodule PUI.Popover.Primitive do
  @moduledoc """
  Zero-style Floating UI popover parts.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :placement, :string, default: "bottom-start"
  attr :trigger, :string, default: "click"
  attr :strategy, :string, default: "auto"
  attr :rest, :global
  slot :inner_block, required: true
  def root(assigns), do: ~H|<div
  id={@id}
  data-placement={@placement}
  data-trigger={@trigger}
  data-strategy={@strategy}
  phx-hook="PUI.Popover"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :id, :string, required: true
  attr :controls, :string, required: true
  attr :haspopup, :string, default: "dialog"
  attr :rest, :global
  slot :inner_block, required: true
  def trigger(assigns), do: ~H|<button
  id={@id}
  type="button"
  aria-haspopup={@haspopup}
  aria-expanded="false"
  aria-controls={@controls}
  {@rest}
>{render_slot(@inner_block)}</button>|

  attr :id, :string, required: true
  attr :role, :string, default: "dialog"
  attr :rest, :global
  slot :inner_block, required: true
  def content(assigns), do: ~H|<div
  id={@id}
  role={@role}
  aria-hidden="true"
  data-side="bottom"
  data-floating-strategy="absolute"
  data-reference-hidden="false"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|
end
