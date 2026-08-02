defmodule PUI.Badge do
  @moduledoc """
  A compact label for statuses, categories, and counts.

  Badge keeps its visual treatment intentionally small and composable. Use the
  `variant` attribute for the standard semantic recipes and `class` to add
  application-specific presentation.

  ## Examples

      <.badge>Default</.badge>
      <.badge variant="secondary">Active</.badge>
      <.badge variant="destructive">Error</.badge>
      <.badge variant="outline">Draft</.badge>

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `variant` | `string` | `"default"` | Style: `"default"`, `"secondary"`, `"destructive"`, or `"outline"` |
  | `class` | `string` | `""` | Additional CSS classes |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `inner_block` | yes | Badge content |
  """

  use Phoenix.Component

  attr :class, :string, default: ""

  attr :variant, :string,
    values: ["default", "secondary", "destructive", "outline"],
    default: "default"

  slot :inner_block

  def badge(assigns) do
    assigns = assign(assigns, :variant_class, variant_class(assigns.variant))

    ~H"""
    <span class={[
      "inline-flex items-center justify-center rounded-full border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
      @variant_class,
      @class
    ]}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp variant_class("default") do
    "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90"
  end

  defp variant_class("secondary") do
    "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90"
  end

  defp variant_class("destructive") do
    "border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60"
  end

  defp variant_class("outline") do
    "text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground"
  end
end
