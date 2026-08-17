defmodule PUI.Flash.Message do
  @moduledoc """
  A flash message payload for `PUI.Flash`.

  Create messages with `new/1` or with the struct literal, then send them
  through `PUI.Flash.send_flash/1,2,3`:

      %PUI.Flash.Message{
        message: "Hello!",           # Required
        type: nil,                    # :info, :success, :warning, :error, or nil
        position: nil,                # Uses the group position when nil
        preset: false,                # True for Phoenix preset toast styling
        duration: nil,                # Seconds; nil uses the group timeout
        auto_dismiss: true,           # Auto-dismiss enabled
        dismissable: true,            # Allow manual dismissal
        show_close: true,             # Show the close button when the group allows it
        class: ""                     # Additional CSS classes
      }

  ## Fields

  | Field | Type | Default | Description |
  |-------|------|---------|-------------|
  | `id` | `string` | generated | Stable identity for updates and dismissals |
  | `icon` | `any` | `nil` | Reserved for provider-owned icon markup |
  | `message` | `string \| HEEx template` | `nil` | Rendered content; required |
  | `type` | `atom` | `nil` | `:info`, `:success`, `:warning`, `:error`, or `nil` |
  | `position` | `string` | `nil` | Viewport position; uses the group position when nil |
  | `preset` | `boolean` | `false` | Render with preset toast styling |
  | `duration` | `integer` | `nil` | Auto-dismiss delay in seconds; `-1` keeps it open |
  | `auto_dismiss` | `boolean` | `true` | Whether the message is auto-dismissed |
  | `dismissable` | `boolean` | `true` | Allow manual dismissal |
  | `show_close` | `boolean` | `true` | Show the close button when the group allows it |
  | `class` | `string` | `""` | Additional CSS classes |
  """

  defstruct id: nil,
            icon: nil,
            message: nil,
            type: nil,
            position: nil,
            preset: false,
            duration: nil,
            auto_dismiss: true,
            dismissable: true,
            class: "",
            show_close: true

  @doc """
  Builds a new flash message with a unique id.

  ## Examples

      PUI.Flash.Message.new("Saved!")

      PUI.Flash.Message.new(~H"<div class=\"flex gap-2\">Custom content</div>")
  """
  def new(message \\ "") do
    %__MODULE__{
      id: "fl#{System.unique_integer([:positive])}",
      message: message
    }
  end
end
