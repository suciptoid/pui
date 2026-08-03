defmodule PUI.DatePicker.Primitive do
  @moduledoc """
  Zero-style date-picker hook parts.

  Calendar rendering remains application-owned; these parts retain the stable
  hook, trigger, popup, and hidden-input contract used by PUI.DatePicker.
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns),
    do: ~H|<div id={@id} phx-hook="PUI.DatePicker" {@rest}>{render_slot(@inner_block)}</div>|

  attr :id, :string, required: true
  attr :controls, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true
  def trigger(assigns), do: ~H|<button
  id={@id}
  type="button"
  aria-haspopup="dialog"
  aria-expanded="false"
  aria-controls={@controls}
  {@rest}
>{render_slot(@inner_block)}</button>|

  attr :id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true
  def content(assigns), do: ~H|<div
  id={@id}
  role="dialog"
  aria-hidden="true"
  data-side="bottom"
  data-floating-strategy="absolute"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :value, :string, default: nil
  attr :rest, :global
  def input(assigns), do: ~H|<input id={@id} type="hidden" name={@name} value={@value} {@rest} />|
end
