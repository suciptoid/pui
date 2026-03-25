defmodule PUI.Alert do
  @moduledoc """
  Alert component for displaying important messages and status updates.

  ## Basic Usage

      <.alert>
        <p>This is an alert message.</p>
      </.alert>

  ## With Icon

      <.alert>
        <:icon>
          <.icon name="hero-information-circle" class="size-5" />
        </:icon>
        <p>Alert with an icon.</p>
      </.alert>

  ## With Title and Description

      <.alert>
        <:icon>
          <.icon name="hero-check-circle" class="size-5" />
        </:icon>
        <:title>Success!</:title>
        <:description>Your changes have been saved successfully.</:description>
      </.alert>

  ## Destructive Variant

  Use the destructive variant for errors and warnings:

      <.alert variant="destructive">
        <:icon>
          <.icon name="hero-exclamation-triangle" class="size-5" />
        </:icon>
        <:title>Error</:title>
        <:description>Something went wrong.</:description>
      </.alert>

  ## Without Description

      <.alert>
        <:icon>
          <.icon name="hero-exclamation-triangle" class="size-5" />
        </:icon>
        <:title>Warning</:title>
      </.alert>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `variant` | `string` | `"default"` | Alert style: "default" or "destructive" |
  | `class` | `string` | `""` | Additional CSS classes |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `icon` | Optional icon displayed at the start |
  | `title` | Alert title text |
  | `description` | Detailed description text |
  | `inner_block` | Custom content (alternative to slots) |
  """

  use Phoenix.Component

  attr :class, :string, default: ""
  attr :variant, :string, values: ["default", "destructive", "unstyled"], default: "default"
  attr :role, :string, default: nil

  slot :icon, required: false

  slot :title, required: false do
    attr :class, :string
  end

  slot :description, required: false do
    attr :class, :string
  end

  slot :inner_block

  def alert(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    variant_class =
      if is_unstyled do
        ""
      else
        case assigns[:variant] do
          "default" ->
            "bg-card text-card-foreground"

          "destructive" ->
            "text-destructive bg-card [&>svg]:text-current *:data-[alert-desc]:text-destructive/90"
        end
      end

    role =
      case assigns[:role] do
        nil ->
          if assigns[:variant] == "destructive", do: "alert", else: "status"

        value ->
          value
      end

    assigns =
      assign(assigns, variant_class: variant_class, is_unstyled: is_unstyled, role: role)

    ~H"""
    <div
      role={@role}
      aria-live={if @role == "alert", do: "assertive", else: "polite"}
      aria-atomic="true"
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "relative w-full rounded-lg border border-border px-4 py-3 text-sm grid grid-cols-[0_1fr] gap-y-0.5 items-start ",
            "has-[>[data-icon]]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>[data-icon]]:gap-x-3 [&>[data-icon]]:size-4 [&>[data-icon]]:text-current",
            @variant_class,
            @class
          ]
        end
      }
    >
      <div :if={@icon !== []} data-icon="alert-icon">
        {render_slot(@icon)}
      </div>
      <.alert_title :if={@title !== []} is_unstyled={@is_unstyled}>
        {render_slot(@title)}
      </.alert_title>
      <.alert_description :if={@description !== []} is_unstyled={@is_unstyled}>
        {render_slot(@description)}
      </.alert_description>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the title of an alert.
  """
  attr :class, :string, default: ""
  attr :is_unstyled, :boolean, default: false
  slot :inner_block

  def alert_title(%{is_unstyled: is_unstyled} = assigns) do
    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div class={
      if @is_unstyled,
        do: [@class],
        else: ["col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight", @class]
    }>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the description of an alert.
  """
  attr :class, :string, default: ""
  attr :is_unstyled, :boolean, default: false
  slot :inner_block

  def alert_description(%{is_unstyled: is_unstyled} = assigns) do
    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div
      data-alert-desc
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed",
            @class
          ]
        end
      }
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
