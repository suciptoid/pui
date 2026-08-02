defmodule PUI.Icon.Heroicons do
  @moduledoc """
  Default CSS-class provider for Phoenix Heroicons.
  """

  use Phoenix.Component

  @behaviour PUI.IconProvider

  @icon_classes %{
    close: "hero-x-mark",
    chevron_down: "hero-chevron-down",
    chevron_left: "hero-chevron-left",
    chevron_right: "hero-chevron-right",
    chevron_up_down: "hero-chevron-up-down",
    search: "hero-magnifying-glass",
    calendar: "hero-calendar",
    menu: "hero-bars-3",
    success: "hero-check-circle",
    error: "hero-x-circle",
    warning: "hero-exclamation-triangle",
    info: "hero-information-circle"
  }

  @impl true
  def render(token, assigns) do
    case Map.fetch(@icon_classes, token) do
      {:ok, icon_class} ->
        assigns = assign(assigns, :icon_class, icon_class)

        ~H"""
        <span class={[@icon_class, @class]} {@rest} />
        """

      :error ->
        raise ArgumentError,
              "PUI.Icon.Heroicons does not support semantic icon token #{inspect(token)}"
    end
  end
end
