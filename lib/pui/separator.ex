defmodule PUI.Separator do
  @moduledoc """
  A visual separator for related content and controls.

  ## Examples

      <.separator />
      <.separator orientation="vertical" class="mx-2 h-5" />
      <.separator decorative={false} aria-label="Section boundary" />

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `orientation` | `string` | `"horizontal"` | `"horizontal"` or `"vertical"` |
  | `decorative` | `boolean` | `true` | Omits separator semantics when true |
  | `class` | `string` | `""` | Additional CSS classes |
  | `rest` | `global` | — | Global HTML attributes |
  """

  use Phoenix.Component

  attr :orientation, :string, values: ["horizontal", "vertical"], default: "horizontal"
  attr :decorative, :boolean, default: true
  attr :class, :string, default: ""
  attr :rest, :global

  def separator(assigns) do
    assigns = assign(assigns, :orientation_class, orientation_class(assigns.orientation))

    ~H"""
    <div
      data-slot="separator"
      data-orientation={@orientation}
      role={if @decorative, do: nil, else: "separator"}
      aria-orientation={if @decorative, do: nil, else: @orientation}
      class={[@orientation_class, @class]}
      {@rest}
    />
    """
  end

  defp orientation_class("horizontal"), do: "h-px w-full shrink-0 bg-border"
  defp orientation_class("vertical"), do: "h-full w-px shrink-0 bg-border"
end
