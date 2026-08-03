defmodule PUI.Tabs.Primitive do
  @moduledoc """
  Zero-style, accessible tab parts backed by the PUI tabs hook.
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :orientation, :string, default: "horizontal"
  attr :activation_mode, :string, default: "manual"
  attr :client_controlled, :boolean, default: true
  attr :rest, :global
  slot :inner_block, required: true
  def root(assigns), do: ~H|<div
  id={@id}
  phx-hook="PUI.Tabs"
  data-orientation={@orientation}
  data-activation-mode={@activation_mode}
  data-client-controlled={to_string(@client_controlled)}
  {@rest}
>
  {render_slot(@inner_block)}
</div>|

  attr :orientation, :string, default: "horizontal"
  attr :rest, :global
  slot :inner_block, required: true

  def list(assigns),
    do:
      ~H|<div role="tablist" aria-orientation={@orientation} {@rest}>{render_slot(@inner_block)}</div>|

  attr :id, :string, required: true
  attr :value, :string, required: true
  attr :selected, :boolean, default: false
  attr :controls, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true
  def trigger(assigns), do: ~H|<button
  id={@id}
  type="button"
  role="tab"
  data-value={@value}
  data-state={if @selected, do: "active", else: "inactive"}
  aria-selected={to_string(@selected)}
  aria-controls={@controls}
  tabindex={if @selected, do: "0", else: "-1"}
  disabled={@disabled}
  data-disabled={if @disabled, do: "true"}
  {@rest}
>{render_slot(@inner_block)}</button>|

  attr :id, :string, required: true
  attr :value, :string, required: true
  attr :selected, :boolean, default: false
  attr :labelledby, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  def panel(assigns), do: ~H|<div
  id={@id}
  role="tabpanel"
  data-value={@value}
  data-state={if @selected, do: "active", else: "inactive"}
  aria-labelledby={@labelledby}
  tabindex="0"
  hidden={not @selected}
  {@rest}
>
  {render_slot(@inner_block)}
</div>|
end
