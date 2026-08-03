defmodule PUI.Accordion do
  @moduledoc """
  Styled native accordion components.

  For fully custom static disclosure markup, use HTML `details` and `summary`
  elements directly.
  """

  use Phoenix.Component
  import PUI.Icon, only: [icon: 1]

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def accordion(assigns),
    do: ~H|<div class={["w-full", @class]} {@rest}>{render_slot(@inner_block)}</div>|

  attr :class, :string, default: ""
  attr :name, :string, default: nil
  attr :open, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def accordion_item(assigns),
    do: ~H|<details name={@name} open={@open} class={["group border-b", @class]} {@rest}>
  {render_slot(@inner_block)}
</details>|

  attr :class, :string, default: ""
  attr :icon, :boolean, default: true
  attr :rest, :global
  slot :inner_block, required: true

  def accordion_trigger(assigns) do
    ~H"""
    <summary
      class={[
        "flex cursor-pointer list-none items-center justify-between py-4 text-sm font-medium",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <.icon
        :if={@icon}
        name={:chevron_down}
        class="size-4 shrink-0 transition-transform group-open:rotate-180"
      />
    </summary>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def accordion_content(assigns),
    do: ~H|<div class={["pb-4 text-sm text-muted-foreground", @class]} {@rest}>
  {render_slot(@inner_block)}
</div>|
end
