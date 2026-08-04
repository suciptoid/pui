defmodule PUI.Dropdown do
  @moduledoc """
  Styled dropdown menus.

  Use `PUI.Dropdown.Primitive` when the application owns menu markup and CSS.
  """

  use Phoenix.Component

  attr :id, :string, default: nil

  attr :variant, :string,
    values: ["default", "secondary", "outline", "ghost", "destructive"],
    default: "secondary"

  attr :rest, :global
  attr :placement, :string, default: "bottom-start"
  attr :wrapper_class, :string, default: "w-fit"
  attr :content_class, :string, default: ""
  attr :class, :string, default: ""
  attr :trigger, :string, default: "click"

  slot :item do
    attr :variant, :string
    attr :class, :string
    attr :shortcut, :string
    attr :href, :string
    attr :navigate, :string
    attr :patch, :string
    attr :"phx-click", :any
    attr :"phx-value-action", :string
  end

  slot :items
  slot :inner_block

  def menu_button(assigns) do
    id = assigns.id || "menu-button-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <PUI.Dropdown.Primitive.root
      id={@id}
      placement={@placement}
      trigger={@trigger}
      class={@wrapper_class}
    >
      <PUI.Button.button
        id={"#{@id}-trigger"}
        type="button"
        variant={@variant}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={"#{@id}-menu"}
        class={@class}
      >
        {render_slot(@inner_block)}
      </PUI.Button.button>
      <.menu_content id={"#{@id}-menu"} class={@content_class}>
        <.menu_item
          :for={item <- @item}
          variant={Map.get(item, :variant, "default")}
          shortcut={Map.get(item, :shortcut)}
          class={Map.get(item, :class)}
          href={Map.get(item, :href)}
          navigate={Map.get(item, :navigate)}
          patch={Map.get(item, :patch)}
          phx-click={Map.get(item, :"phx-click")}
          phx-value-action={Map.get(item, :"phx-value-action")}
        >
          {render_slot(item)}
        </.menu_item>
        {render_slot(@items)}
      </.menu_content>
    </PUI.Dropdown.Primitive.root>
    """
  end

  attr :id, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block

  def menu_content(assigns) do
    ~H"""
    <PUI.Dropdown.Primitive.content
      id={@id}
      class={[
        "aria-hidden:hidden block bg-popover text-popover-foreground",
        "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
        "z-50 min-w-32 overflow-x-hidden overflow-y-auto rounded-md border border-border p-1 shadow-md",
        "origin-top data-[reference-hidden=true]:invisible data-[reference-hidden=true]:pointer-events-none data-[side=left]:origin-right data-[side=right]:origin-left data-[side=top]:origin-bottom",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </PUI.Dropdown.Primitive.content>
    """
  end

  attr :rest, :global
  slot :inner_block

  def menu_shortcut(assigns),
    do:
      ~H|<span class="ml-auto text-xs tracking-widest text-muted-foreground" {@rest}>{render_slot(
  @inner_block
)}</span>|

  attr :class, :string, default: ""
  attr :shortcut, :string, default: nil
  attr :variant, :string, values: ["default", "destructive"], default: "default"

  attr :rest, :global,
    include:
      ~w(href navigate patch method download name value disabled phx-click phx-value-action)

  slot :inner_block

  def menu_item(%{rest: rest} = assigns) do
    classes = [
      "relative flex w-full cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-left text-sm outline-hidden select-none focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground",
      assigns.variant == "destructive" && "text-destructive",
      assigns.class
    ]

    assigns = assign(assigns, :classes, classes)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H|<.link data-variant={@variant} role="menuitem" class={@classes} {@rest}>{render_slot(@inner_block)}
<.menu_shortcut :if={@shortcut}>{@shortcut}</.menu_shortcut></.link>|
    else
      ~H|<button type="button" data-variant={@variant} role="menuitem" class={@classes} {@rest}>{render_slot(
  @inner_block
)}
<.menu_shortcut :if={@shortcut}>{@shortcut}</.menu_shortcut></button>|
    end
  end

  attr :rest, :global

  def menu_separator(assigns),
    do:
      ~H|<div role="separator" aria-orientation="horizontal" class="bg-border -mx-1 my-1 h-px" {@rest} />|
end
