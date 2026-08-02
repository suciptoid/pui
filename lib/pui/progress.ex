defmodule PUI.Progress do
  @moduledoc """
  An accessible progress bar for completion and loading states.

  The component renders a `progressbar` role with configurable bounds and
  accessible labels. The host application owns the value and can update it
  through ordinary LiveView assigns.

  ## Examples

      <.progress value={42} label="Upload progress" />
      <.progress value={3} min={0} max={10} value_text="3 of 10 items" />
      <.progress value={75} class="h-3" />

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `min` | `float` | `0.0` | Minimum progress value |
  | `max` | `float` | `100.0` | Maximum progress value |
  | `value` | `float` | `0.0` | Current progress value |
  | `label` | `string` | `nil` | Accessible label for the progressbar |
  | `aria_labelledby` | `string` | `nil` | ID of an element labelling the progressbar |
  | `value_text` | `string` | `nil` | Human-readable value announced by screen readers |
  | `class` | `string` | `""` | Additional CSS classes |
  """

  use Phoenix.Component

  attr :min, :float, default: 0.0
  attr :max, :float, default: 100.0
  attr :value, :float, default: 0.0
  attr :label, :string, default: nil
  attr :aria_labelledby, :string, default: nil
  attr :value_text, :string, default: nil
  attr :class, :string, default: ""

  def progress(assigns) do
    ~H"""
    <div
      role="progressbar"
      aria-label={@label}
      aria-labelledby={@aria_labelledby}
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuetext={@value_text}
      class={[
        "bg-primary/20 relative h-2 w-full overflow-hidden rounded-full",
        @class
      ]}
    >
      <div
        style={"transform: translateX(-#{100 - (@value || 0)}%)"}
        class="bg-primary h-full w-full flex-1 transition-all"
      >
      </div>
    </div>
    """
  end
end
