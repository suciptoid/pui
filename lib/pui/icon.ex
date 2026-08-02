defmodule PUI.Icon do
  @moduledoc """
  Provider-backed icons for PUI-owned affordances.

  PUI uses semantic icon tokens so its internal controls do not depend on one
  icon library. The default provider renders Heroicons CSS classes. Configure a
  host provider with `config :pui, :icon_provider, MyApp.PUIIcons` when using
  Lucide, Tabler, or another icon system.

  Application-specific icons should normally be rendered by the host
  application's icon component and passed through component slots.

  ## Examples

      <PUI.Icon.icon name={:close} />
      <PUI.Icon.icon name={:calendar} class="size-5 text-primary" />

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `name` | `atom` | required | PUI semantic icon token |
  | `class` | `string` | `"size-4"` | Additional icon classes |
  | `rest` | `global` | — | Global HTML attributes passed to the provider |
  """

  use Phoenix.Component

  @tokens [
    :close,
    :chevron_down,
    :chevron_left,
    :chevron_right,
    :chevron_up_down,
    :search,
    :calendar,
    :menu,
    :success,
    :error,
    :warning,
    :info
  ]

  attr :name, :atom, required: true, values: @tokens
  attr :class, :string, default: "size-4"
  attr :rest, :global

  def icon(assigns) do
    provider = Application.get_env(:pui, :icon_provider, PUI.Icon.Heroicons)
    rest = Map.put_new(assigns.rest, "aria-hidden", "true")
    assigns = assign(assigns, :rest, rest)

    provider_loaded? =
      case Code.ensure_loaded(provider) do
        {:module, _module} -> function_exported?(provider, :render, 2)
        {:error, _reason} -> false
      end

    unless provider_loaded? do
      raise ArgumentError,
            "PUI icon provider #{inspect(provider)} must implement render/2"
    end

    apply(provider, :render, [assigns.name, assigns])
  end
end
