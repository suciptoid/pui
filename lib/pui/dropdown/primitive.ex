defmodule PUI.Dropdown.Primitive do
  @moduledoc """
  Zero-style menu parts backed by the PUI popover hook.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :placement, :string, default: "bottom-start"
  attr :trigger, :string, default: "click"
  attr :rest, :global
  slot :inner_block, required: true
  def root(assigns), do: PUI.Popover.Primitive.root(assigns)

  attr :id, :string, required: true
  attr :controls, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true
  def trigger(assigns), do: PUI.Popover.Primitive.trigger(assign(assigns, :haspopup, "menu"))

  attr :id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true
  def content(assigns), do: PUI.Popover.Primitive.content(assign(assigns, :role, "menu"))

  attr :rest, :global, include: ~w(href navigate patch method download disabled)
  slot :inner_block, required: true

  def item(%{rest: rest} = assigns) do
    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H|<.link role="menuitem" {@rest}>{render_slot(@inner_block)}</.link>|
    else
      ~H|<button type="button" role="menuitem" {@rest}>{render_slot(@inner_block)}</button>|
    end
  end

  attr :rest, :global
  def separator(assigns), do: ~H|<div role="separator" aria-orientation="horizontal" {@rest} />|
end
