defmodule PUI.Empty do
  @moduledoc """
  A composable empty state for collections and pages without content.

  Empty states keep the explanation and next action in host-owned slots while
  PUI supplies the accessible structure and default presentation.

  ## Example

      <.empty>
        <:icon><PUI.Icon.icon name={:search} class="size-6" /></:icon>
        <:title>No projects yet</:title>
        <:description>Create a project to start organizing your work.</:description>
        <:actions>
          <.button>Create project</.button>
        </:actions>
      </.empty>

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `class` | `string` | `""` | Additional CSS classes |
  | `rest` | `global` | — | Global HTML attributes |

  ## Slots

  | Slot | Required | Description |
  |------|----------|-------------|
  | `icon` | no | Application-owned or semantic icon |
  | `title` | yes | Empty-state heading |
  | `description` | no | Supporting explanation |
  | `actions` | no | Recovery or creation actions |
  | `inner_block` | no | Additional content below the actions |
  """

  use Phoenix.Component

  attr :variant, :string, values: ["default", "unstyled"], default: "default"
  attr :class, :string, default: ""
  attr :rest, :global

  slot :icon
  slot :title, required: true
  slot :description
  slot :actions
  slot :inner_block

  def empty(assigns) do
    assigns = assign(assigns, :unstyled?, assigns.variant == "unstyled")

    ~H"""
    <section
      data-slot="empty"
      class={[
        !@unstyled? &&
          "flex min-h-56 flex-col items-center justify-center gap-6 rounded-xl border border-dashed p-8 text-center",
        @class
      ]}
      {@rest}
    >
      <div class={[
        !@unstyled? && "mx-auto flex max-w-sm flex-col items-center gap-2 text-center"
      ]}>
        <div
          :if={@icon != []}
          data-slot="empty-icon"
          class={
            !@unstyled? &&
              "bg-muted text-muted-foreground flex size-12 items-center justify-center rounded-full"
          }
        >
          {render_slot(@icon)}
        </div>
        <h2 data-slot="empty-title" class={!@unstyled? && "text-lg font-semibold"}>
          {render_slot(@title)}
        </h2>
        <p
          :if={@description != []}
          data-slot="empty-description"
          class={!@unstyled? && "text-muted-foreground text-sm"}
        >
          {render_slot(@description)}
        </p>
      </div>
      <div :if={@actions != []} data-slot="empty-actions" class="flex items-center gap-2">
        {render_slot(@actions)}
      </div>
      {render_slot(@inner_block)}
    </section>
    """
  end
end
