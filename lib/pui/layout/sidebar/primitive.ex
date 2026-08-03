defmodule PUI.Layout.Sidebar.Primitive do
  @moduledoc """
  Zero-style parts for the persistent PUI sidebar hook.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :collapsed, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true
  def root(assigns), do: ~H|<aside
  id={@id}
  data-collapsed={to_string(@collapsed)}
  data-shell={@id}
  phx-hook="PUI.Sidebar"
  {@rest}
>
  {render_slot(@inner_block)}
</aside>|

  attr :id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def toggle(assigns),
    do: ~H|<button id={@id} type="button" {@rest}>{render_slot(@inner_block)}</button>|
end
