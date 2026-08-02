defmodule PUI.Avatar do
  @moduledoc """
  An avatar with a host-controlled fallback.

  Avatar renders an image when `src` is present and the fallback when it is not.
  It deliberately does not add a JavaScript error handler; applications that
  need a fallback after a failed remote image request can own that behavior
  through the forwarded global attributes.

  ## Examples

      <.avatar src={@user.avatar_url} alt={@user.name} fallback_text="SC" />

      <.avatar alt="Team" size="lg">
        <:fallback>TM</:fallback>
      </.avatar>

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `src` | `string` | `nil` | Image source; fallback renders when absent |
  | `alt` | `string` | `""` | Image alternative text |
  | `fallback_text` | `string` | `nil` | Text shown when no image exists |
  | `size` | `string` | `"default"` | `"sm"`, `"default"`, or `"lg"` |
  | `class` | `string` | `""` | Additional CSS classes |
  | `rest` | `global` | — | Global HTML attributes |

  ## Slots

  | Slot | Required | Description |
  |------|----------|-------------|
  | `fallback` | no | Custom fallback content |
  """

  use Phoenix.Component

  attr :src, :string, default: nil
  attr :alt, :string, default: ""
  attr :fallback_text, :string, default: nil
  attr :size, :string, values: ["sm", "default", "lg"], default: "default"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :fallback

  def avatar(assigns) do
    assigns =
      assigns
      |> assign(:size_class, size_class(assigns.size))
      |> assign(:has_image?, is_binary(assigns.src) and assigns.src != "")

    ~H"""
    <span
      data-slot="avatar"
      class={[
        "bg-muted relative flex shrink-0 overflow-hidden rounded-full",
        @size_class,
        @class
      ]}
      {@rest}
    >
      <img :if={@has_image?} src={@src} alt={@alt} class="aspect-square size-full object-cover" />
      <span
        :if={!@has_image?}
        data-slot="avatar-fallback"
        class="bg-muted text-muted-foreground flex size-full items-center justify-center rounded-full text-xs font-medium"
      >
        <%= if @fallback != [] do %>
          {render_slot(@fallback)}
        <% else %>
          {@fallback_text}
        <% end %>
      </span>
    </span>
    """
  end

  defp size_class("sm"), do: "size-8"
  defp size_class("default"), do: "size-10"
  defp size_class("lg"), do: "size-12"
end
