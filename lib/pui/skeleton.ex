defmodule PUI.Skeleton do
  @moduledoc """
  An accessible loading placeholder.

  Skeleton is intentionally presentation-only. The host application decides
  when to render it and how much content to reserve.

  ## Examples

      <.skeleton class="h-4 w-48" />
      <.skeleton class="h-24 w-full rounded-xl" data-testid="loading-projects" />

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `class` | `string` | `""` | Size and additional CSS classes |
  | `rest` | `global` | — | Global HTML attributes |
  """

  use Phoenix.Component

  attr :class, :string, default: ""
  attr :rest, :global

  def skeleton(assigns) do
    ~H"""
    <div
      data-slot="skeleton"
      aria-hidden="true"
      class={["animate-pulse rounded-md bg-muted", @class]}
      {@rest}
    />
    """
  end
end
