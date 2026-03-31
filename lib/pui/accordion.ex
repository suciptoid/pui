defmodule PUI.Accordion do
  @moduledoc """
  Accordion primitives for progressively revealing related content.

  The components in this module use the native HTML `<details>` and `<summary>`
  elements, so they work without extra JavaScript while still matching the
  shadcn-inspired styling used throughout PUI.

  Use `accordion/1` as the outer wrapper, then compose it with
  `accordion_item/1`, `accordion_trigger/1`, and `accordion_content/1`.

  Items that share the same `name` attribute behave like a single-open group,
  while items without `name` can all stay open at the same time.

  ## Basic Usage

      <.accordion class="max-w-xl">
        <.accordion_item name="faq" open>
          <.accordion_trigger>Is it accessible?</.accordion_trigger>
          <.accordion_content>
            Yes. It uses native details and summary elements.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item name="faq">
          <.accordion_trigger>Can I open multiple items?</.accordion_trigger>
          <.accordion_content>
            Omit the shared `name` attribute to allow multiple open items.
          </.accordion_content>
        </.accordion_item>
      </.accordion>

  ## Unstyled / Headless

  Use `variant="unstyled"` on each primitive when you want PUI to keep the
  structure but leave presentation entirely up to you:

      <.accordion variant="unstyled" class="space-y-3">
        <.accordion_item variant="unstyled" class="rounded-2xl border">
          <.accordion_trigger
            variant="unstyled"
            class="flex w-full items-center justify-between px-4 py-3"
          >
            Custom trigger
          </.accordion_trigger>
          <.accordion_content variant="unstyled" class="px-4 pb-4 text-sm">
            Fully custom content styling.
          </.accordion_content>
        </.accordion_item>
      </.accordion>

  ## Attributes

  ### `accordion/1`

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `class` | `string` | `""` | Additional wrapper classes |
  | `rest` | `global` | - | Global HTML attributes |

  ### `accordion_item/1`

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `name` | `string` | `nil` | Shared group name for single-open behavior |
  | `open` | `boolean` | `false` | Whether the item starts expanded |
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `class` | `string` | `""` | Additional item classes |

  ### `accordion_trigger/1`

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `icon` | `boolean` | `true` | Show the default chevron icon |
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `class` | `string` | `""` | Additional trigger classes |

  ### `accordion_content/1`

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `variant` | `string` | `"default"` | `"default"` or `"unstyled"` |
  | `class` | `string` | `""` | Additional content classes |

  ## Slots

  | Slot | Description |
  |------|-------------|
  | `inner_block` | The nested content for each primitive |
  """

  use Phoenix.Component

  attr :class, :string, default: ""
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders the outer accordion wrapper.

  The wrapper is intentionally lightweight. Single-open behavior is controlled
  by giving related `accordion_item/1` entries the same `name` attribute.

  ## Examples

      <.accordion class="max-w-xl">
        <.accordion_item name="faq" open>
          <.accordion_trigger>Question</.accordion_trigger>
          <.accordion_content>Answer</.accordion_content>
        </.accordion_item>
      </.accordion>
  """
  def accordion(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div
      class={
        if @is_unstyled do
          [@class]
        else
          ["w-full", @class]
        end
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :name, :string, default: nil
  attr :open, :boolean, default: false
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders a single accordion item using the native `<details>` element.

  Use the same `name` on sibling items to create single-open behavior similar
  to a traditional accordion. Leave `name` empty to allow multiple items to
  stay expanded.

  ## Examples

      <.accordion_item name="faq" open>
        <.accordion_trigger>Question</.accordion_trigger>
        <.accordion_content>Answer</.accordion_content>
      </.accordion_item>
  """
  def accordion_item(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <details
      name={@name}
      open={@open}
      class={
        if @is_unstyled do
          [@class]
        else
          ["group border-b border-border", @class]
        end
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </details>
    """
  end

  attr :class, :string, default: ""
  attr :icon, :boolean, default: true
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders the clickable accordion summary row.

  By default the trigger includes a chevron that rotates when its parent item
  is open. Set `icon={false}` to hide it.

  ## Examples

      <.accordion_trigger>Billing & shipping</.accordion_trigger>
      <.accordion_trigger icon={false}>Plain trigger</.accordion_trigger>
  """
  def accordion_trigger(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <summary
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "focus-visible:border-ring focus-visible:ring-ring/50 flex w-full items-center justify-between gap-4 py-4 text-left text-sm font-medium outline-none transition-all focus-visible:ring-[3px] hover:underline",
            "[&::-webkit-details-marker]:hidden [&::marker]:hidden",
            @class
          ]
        end
      }
      {@rest}
    >
      <span class="flex-1">{render_slot(@inner_block)}</span>
      <svg
        :if={@icon}
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        aria-hidden="true"
        class="size-4 shrink-0 text-muted-foreground transition-transform duration-200 group-open:rotate-180"
      >
        <path
          fill-rule="evenodd"
          d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.168l3.71-3.938a.75.75 0 1 1 1.08 1.04l-4.25 4.512a.75.75 0 0 1-1.08 0L5.21 8.27a.75.75 0 0 1 .02-1.06Z"
          clip-rule="evenodd"
        />
      </svg>
    </summary>
    """
  end

  attr :class, :string, default: ""
  attr :variant, :string, default: "default", values: ["default", "unstyled"]
  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Renders the accordion panel content below a trigger.

  Place this component directly after `accordion_trigger/1` inside an
  `accordion_item/1`.

  ## Examples

      <.accordion_content>
        Answers, body copy, and custom markup go here.
      </.accordion_content>
  """
  def accordion_content(%{variant: variant} = assigns) do
    is_unstyled = variant == "unstyled"

    assigns = assign(assigns, :is_unstyled, is_unstyled)

    ~H"""
    <div
      class={
        if @is_unstyled do
          [@class]
        else
          ["pb-4 text-sm text-muted-foreground", @class]
        end
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
