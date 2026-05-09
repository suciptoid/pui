defmodule PUI.ButtonGroup do
  @moduledoc """
  A container that groups related buttons together with consistent styling.

  ## Basic Usage

      <.button_group>
        <.button variant="outline">Button 1</.button>
        <.button variant="outline">Button 2</.button>
      </.button_group>

  ## With Separator

  Visually divide buttons within a group. Separators are most useful with
  non-outline variants since outline buttons already have visible borders.

      <.button_group>
        <.button variant="secondary">Copy</.button>
        <.button_group_separator />
        <.button variant="secondary">Paste</.button>
      </.button_group>

  ## With Text

  Add a text label within the group:

      <.button_group>
        <.button_group_text>Label</.button_group_text>
        <.button variant="outline">Action</.button>
      </.button_group>

  ## Vertical Orientation

      <.button_group orientation="vertical">
        <.button variant="outline" size="icon">
          <.icon name="hero-plus" />
        </.button>
        <.button variant="outline" size="icon">
          <.icon name="hero-minus" />
        </.button>
      </.button_group>

  ## Nested Groups

  Nest button groups to create complex layouts with spacing between sub-groups:

      <.button_group>
        <.button_group>
          <.button variant="outline" size="icon">
            <.icon name="hero-plus" />
          </.button>
        </.button_group>
        <.button_group>
          <.input placeholder="Search..." />
        </.button_group>
      </.button_group>

  ## Split Button

  Create a split button by combining a button with a separator and an icon button:

      <.button_group>
        <.button variant="secondary">Send</.button>
        <.button_group_separator />
        <.button variant="secondary" size="icon">
          <.icon name="hero-chevron-down" />
        </.button>
      </.button_group>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `orientation` | `string` | `"horizontal"` | Layout direction: `"horizontal"` or `"vertical"` |
  | `class` | `string` | `""` | Additional CSS classes |
  | `rest` | `global` | - | HTML attributes including `aria-label` |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `inner_block` | Group content (required) — typically buttons, separators, or text |

  ## Accessibility

  - The container has `role="group"` for assistive technologies.
  - Use `aria-label` or `aria-labelledby` to describe the group's purpose.
  - Use `Tab` to navigate between buttons in the group.
  """

  use Phoenix.Component

  attr :orientation, :string, values: ["horizontal", "vertical"], default: "horizontal"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def button_group(assigns) do
    orientation_class =
      case assigns.orientation do
        "horizontal" ->
          "[&>*:not(:last-child)]:rounded-r-none [&>*:not(:first-child)]:rounded-l-none [&>*+*]:-ml-px"

        "vertical" ->
          "flex-col [&>*:not(:last-child)]:rounded-b-none [&>*:not(:first-child)]:rounded-t-none [&>*+*]:-mt-px"
      end

    assigns = assign(assigns, orientation_class: orientation_class)

    ~H"""
    <div
      role="group"
      class={[
        "flex items-stretch",
        "[&>*:focus-within]:relative [&>*:focus-within]:z-10",
        @orientation_class,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  A visual separator between buttons within a button group.

  Use this to visually divide buttons in a group, especially with non-outline
  variants. Outline buttons already have visible borders and typically don't
  need a separator.

  ## Usage

      <.button_group>
        <.button variant="secondary">Copy</.button>
        <.button_group_separator />
        <.button variant="secondary">Paste</.button>
      </.button_group>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `orientation` | `string` | `"horizontal"` | Separator direction: `"horizontal"` (vertical line) or `"vertical"` (horizontal line) |
  | `class` | `string` | `""` | Additional CSS classes |
  """
  attr :orientation, :string, values: ["horizontal", "vertical"], default: "horizontal"
  attr :class, :string, default: ""

  def button_group_separator(assigns) do
    ~H"""
    <div
      role="separator"
      aria-orientation={@orientation}
      class={[
        "bg-border shrink-0",
        if(@orientation == "horizontal",
          do: "w-px self-stretch",
          else: "h-px w-full"
        ),
        @class
      ]}
    />
    """
  end

  @doc """
  Displays text content within a button group, typically used as a label.

  ## Usage

      <.button_group>
        <.button_group_text>Prefix</.button_group_text>
        <.button variant="outline">Action</.button>
      </.button_group>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `class` | `string` | `""` | Additional CSS classes |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `inner_block` | Text content (required) |
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def button_group_text(assigns) do
    ~H"""
    <div class={[
      "inline-flex items-center px-3 text-sm text-muted-foreground border border-border bg-muted",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
