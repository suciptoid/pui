defmodule PUI.Popover do
  @moduledoc """
  Popover and tooltip components using Floating UI for positioning.

  ## Base Popover

  The base popover provides low-level building blocks for custom popover UIs:

      <.popover_base
        id="my-popover"
        phx-hook="PUI.Popover"
        data-placement="bottom"
      >
        <.button aria-haspopup="menu">Click Me</.button>

        <:popup class="aria-hidden:hidden block p-4 bg-popover rounded-md shadow-md">
          <p>Popover content here</p>
        </:popup>
      </.popover_base>

  ## Tooltip

  Tooltips appear on hover with configurable placement:

      <.tooltip id="tooltip-1" placement="top">
        <.button>Hover me</.button>
        <:tooltip>This is a tooltip</:tooltip>
      </.tooltip>

  ### Placement Options

      <.tooltip placement="top">...</.tooltip>
      <.tooltip placement="bottom">...</.tooltip>
      <.tooltip placement="left">...</.tooltip>
      <.tooltip placement="right">...</.tooltip>

  ### Variants

      <.tooltip variant="default">...</.tooltip>
      <.tooltip variant="light">...</.tooltip>
      <.tooltip variant="dark">...</.tooltip>
      <.tooltip variant="unstyled">...</.tooltip>

  ### Custom Arrow Color

      <.tooltip arrow_class="bg-blue-500 fill-blue-500">...</.tooltip>

  ## With Icons

      <.tooltip id="icon-tooltip" placement="bottom">
        <.icon name="hero-information-circle" class="size-5" />
        <:tooltip>More information about this</:tooltip>
      </.tooltip>

  ## Rich Content

      <.tooltip id="rich-tooltip">
        <.button>Hover for details</.button>
        <:tooltip>
          <div class="w-[200px]">
            <img src="..." class="rounded-t-md" />
            <div class="p-2">
              <p class="font-medium">Title</p>
              <p class="text-sm">Description text</p>
            </div>
          </div>
        </:tooltip>
      </.tooltip>

  ## Attributes (base/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | required | Unique identifier |
  | `hook` | `string` | `"Popover"` | Phoenix hook name |

  ## Attributes (tooltip/1)

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | auto-generated | Unique identifier |
  | `placement` | `string` | `"top"` | Tooltip position |
  | `variant` | `string` | `"default"` | Visual variant: `"default"` (dark), `"light"`, `"dark"`, `"unstyled"` |
  | `arrow_class` | `string` | `""` | Custom CSS classes for the arrow element |
  | `class` | `string` | `""` | Additional CSS classes |

  ## Slots (base/1)

  | Slot | Description |
  |------|-------------|
  | `trigger` | The element that triggers the popover |
  | `popup` | The popover content |
  | `inner_block` | Alternative to trigger slot |

  ## Slots (tooltip/1)

  | Slot | Description |
  |------|-------------|
  | `inner_block` | The element that triggers the tooltip |
  | `tooltip` | The tooltip content |
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  attr :hook, :string, default: "Popover"

  slot :trigger, doc: "Trigger for the popover" do
    attr :class, :string, doc: "Trigger class"
    attr :role, :string, doc: "Trigger aria role"
  end

  slot :popup, doc: "Popup for the popover" do
    attr :class, :string, doc: "Popup class"
    attr :role, :string, doc: "Popup role"
  end

  slot :inner_block,
    doc: "Inner block / children for the popover, can be used for non <button> custom trigger "

  def base(assigns) do
    ~H"""
    <div id={@id} {@rest}>
      <%!-- Trigger --%>
      <button
        :for={t <- @trigger}
        type="button"
        class={Map.get(t, :class, "")}
        role={Map.get(t, :role)}
        id={"#{@id}-trigger"}
        aria-controls={"#{@id}-listbox"}
        aria-haspopup="listbox"
        aria-expanded="false"
      >
        {render_slot(t)}
      </button>
      <%= if @trigger == [] do %>
        {render_slot(@inner_block)}
      <% end %>
      <%!-- Popover --%>
      <div
        :for={p <- @popup}
        id={"#{@id}-listbox"}
        role={Map.get(p, :role, "listbox")}
        aria-hidden="true"
        class={Map.get(p, :class, "")}
      >
        {render_slot(p)}
      </div>
    </div>
    """
  end

  @doc """

  """
  attr :id, :string
  attr :class, :string, default: ""
  attr :container_class, :string, default: ""
  attr :variant, :string, default: "default", values: ["default", "light", "dark", "unstyled"]
  attr :arrow_class, :string, default: ""
  attr :placement, :string, values: ["top", "bottom", "left", "right"], default: "top"
  slot :inner_block

  slot :tooltip do
    attr :class, :string
  end

  def tooltip(%{variant: variant} = assigns) do
    assigns = assign_new(assigns, :id, fn -> "tooltip#{System.unique_integer()}" end)
    is_unstyled = variant == "unstyled"
    is_light = variant == "light"

    assigns =
      assigns
      |> assign(:is_unstyled, is_unstyled)
      |> assign(:is_light, is_light)
      |> assign(:tooltip_id, "#{assigns.id}-tooltip")

    ~H"""
    <div
      id={@id}
      class={["group", @container_class, @container_class == "" && "w-fit"]}
      data-placement={@placement}
      phx-hook="PUI.Tooltip"
      aria-describedby={@tooltip_id}
    >
      {render_slot(@inner_block)}

      <div
        :if={@tooltip != []}
        role="tooltip"
        id={@tooltip_id}
        aria-hidden="true"
        data-placement={@placement}
        class={
          if @is_unstyled do
            [@class]
          else
            [
              "before:absolute before:inset-0 before:z-0 before:bg-inherit before:rounded-[inherit] before:pointer-events-none",
              @is_light && "bg-white text-foreground border border-border shadow-sm",
              !@is_light && "bg-foreground text-background",
              "duration-100 transition ease-in transform",
              "data-[placement=top]:translate-y-0 data-[placement=top]:aria-hidden:translate-y-2",
              "data-[placement=bottom]:translate-y-0 data-[placement=bottom]:aria-hidden:-translate-y-2",
              "data-[placement=right]:translate-x-0 data-[placement=right]:aria-hidden:-translate-x-2",
              "data-[placement=left]:translate-x-0 data-[placement=left]:aria-hidden:-translate-x-2",
              "opacity-100 aria-hidden:opacity-0",
              "aria-hidden:pointer-events-none",
              "invisible not-aria-hidden:visible",
              "z-50 w-fit rounded-md px-3 py-1.5 text-sm text-balance",
              @class
            ]
          end
        }
      >
        <div class="relative z-10">{render_slot(@tooltip)}</div>

        <div
          :if={not @is_unstyled}
          data-arrow
          class={[
            "absolute z-[-1] size-2.5 rotate-45",
            @arrow_class != "" && @arrow_class,
            @arrow_class == "" && @is_light && "bg-white ring-1 ring-border shadow-sm",
            @arrow_class == "" && !@is_light && "bg-foreground"
          ]}
        >
        </div>
      </div>
    </div>
    """
  end
end
