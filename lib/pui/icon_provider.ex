defmodule PUI.IconProvider do
  @moduledoc """
  Behaviour for rendering PUI's semantic icon tokens.

  A provider translates PUI-owned icon intent into the host application's icon
  markup. PUI ships a CSS-class Heroicons provider, while applications can
  configure providers for Lucide, Tabler, or their own icon component.
  """

  @type token ::
          :close
          | :chevron_down
          | :chevron_left
          | :chevron_right
          | :chevron_up_down
          | :search
          | :calendar
          | :menu
          | :success
          | :error
          | :warning
          | :info

  @callback render(token(), map()) :: Phoenix.LiveView.Rendered.t()
end
