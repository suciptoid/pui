# Headless Component Library Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Maui into a headless component library with three usage levels: low-level floating-ui hooks, medium-level unstyled components, and high-level styled components.

**Architecture:** Add `variant="unstyled"` to all components. When unstyled, components render zero default styles while preserving all ARIA attributes and behavior. Existing `class` attribute behavior preserved - appends to styled variants, fully controls unstyled variants. Expose floating-ui hooks directly for low-level usage.

**Tech Stack:** Elixir/Phoenix LiveView, Tailwind CSS, Floating UI (@floating-ui/dom), Phoenix LiveView JS hooks

---

## Architecture Overview

### Three Usage Levels

**Level 1: Low-level Hooks** (direct floating-ui access)
```elixir
<.popover_base phx-hook="Maui.Popover">
  <.button>Trigger</.button>
  <:popup class="fully-custom">Content</:popup>
</.popover_base>
```

**Level 2: Medium-level Unstyled Components** (headless with behavior)
```elixir
<.menu_button variant="unstyled" class="my-btn">
  Open
  <:item class="my-item">Profile</:item>
</.menu_button>
```

**Level 3: High-level Styled Components** (current default)
```elixir
<.menu_button variant="secondary" class="w-full">
  Open
  <:item>Profile</:item>
</.menu_button>
```

### Key Design Decisions

1. **Variant Pattern**: Add `"unstyled"` to `variant` attribute values
2. **Class Behavior**: 
   - Styled variants: `class` appends to default styles (current behavior)
   - Unstyled variant: `class` is the only styling applied
3. **Slot Classes**: All slots support `class` attribute
4. **ARIA Preservation**: Unstyled components maintain all accessibility features
5. **Hook Independence**: JS hooks don't rely on specific CSS classes

---

## Task 1: Button Component - Unstyled Variant

**Files:**
- Modify: `lib/maui/button.ex:72-74`
- Test: `test/maui/button_test.exs`

**Step 1: Add unstyled to variant values**

Modify `lib/maui/button.ex:72-74`:

```elixir
attr :variant, :string,
  values: ["default", "destructive", "outline", "secondary", "ghost", "link", "unstyled"],
  default: "default"
```

**Step 2: Update button function to handle unstyled**

Modify `lib/maui/button.ex:81-124`:

```elixir
def button(%{rest: rest} = assigns) do
  is_unstyled = assigns.variant == "unstyled"
  
  variant_class =
    if is_unstyled do
      ""
    else
      case assigns.variant do
        "default" ->
          "bg-primary text-primary-foreground hover:bg-primary/90"

        "destructive" ->
          "bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60"

        "outline" ->
          "border border-border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50"

        "secondary" ->
          "bg-secondary text-secondary-foreground hover:bg-secondary/80"

        "ghost" ->
          "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50"

        "link" ->
          "text-primary underline-offset-4 hover:underline"
      end
    end

  size_class =
    if is_unstyled do
      ""
    else
      case assigns.size do
        "default" -> "h-9 px-4 py-2 has-[>svg]:px-3"
        "sm" -> "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5"
        "lg" -> "h-10 rounded-md px-6 has-[>svg]:px-4"
        "icon" -> "size-9"
      end
    end

  override_class = Map.get(assigns, :class, "")
  
  base_classes =
    if is_unstyled do
      []
    else
      ["inline-flex active:translate-y-px items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive"]
    end

  assigns =
    assign(assigns,
      class: base_classes ++ [variant_class, size_class, override_class] |> Enum.filter(&(&1 != "")),
      size_class: size_class,
      variant_class: variant_class
    )

  if rest[:href] || rest[:navigate] || rest[:patch] do
    ~H"""
    <.link class={@class} {@rest}>
      {render_slot(@inner_block)}
    </.link>
    """
  else
    ~H"""
    <button class={@class} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end
end
```

**Step 3: Write tests for unstyled button**

Create `test/maui/button_test.exs`:

```elixir
defmodule Maui.ButtonTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Button

  describe "button with variant='unstyled'" do
    test "renders with only custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.button variant="unstyled" class="px-4 py-2 bg-blue-500">
        Custom Button
      </.button>
      """)
      
      assert html =~ "px-4 py-2 bg-blue-500"
      refute html =~ "bg-primary"
      refute html =~ "h-9"
    end

    test "renders without default variant classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.button variant="unstyled">Unstyled</.button>
      """)
      
      refute html =~ "bg-primary"
      refute html =~ "bg-secondary"
      refute html =~ "rounded-md"
    end

    test "preserves button element type" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.button variant="unstyled">Unstyled</.button>
      """)
      
      assert html =~ "<button"
    end
  end

  describe "styled button behavior" do
    test "class appends to styled variant" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.button variant="secondary" class="w-full">
        Styled Button
      </.button>
      """)
      
      assert html =~ "bg-secondary"
      assert html =~ "w-full"
    end
  end
end
```

**Step 4: Run tests**

Run: `mix test test/maui/button_test.exs`
Expected: All tests pass

**Step 5: Commit**

```bash
git add lib/maui/button.ex test/maui/button_test.exs
git commit -m "feat(button): add unstyled variant support"
```

---

## Task 2: Dropdown/MenuButton - Unstyled Variant with Slot Classes

**Files:**
- Modify: `lib/maui/dropdown.ex:87-89`
- Test: `test/maui/dropdown_test.exs`

**Step 1: Add variant attribute to menu_button**

Modify `lib/maui/dropdown.ex:87-89`:

```elixir
attr :variant, :string,
  default: "secondary",
  values: ["default", "secondary", "outline", "ghost", "destructive", "unstyled"],
  doc: "see Button variant. Use 'unstyled' for headless mode"
```

**Step 2: Update menu_button function to handle unstyled**

Modify `lib/maui/dropdown.ex:106-138`:

```elixir
def menu_button(%{rest: rest, variant: variant} = assigns) do
  id = rest[:id] || "dropdown-#{System.unique_integer([:positive])}"
  is_unstyled = variant == "unstyled"

  assigns = assign(assigns, id: id, is_unstyled: is_unstyled)

  ~H"""
  <div id={@id} class="w-fit" phx-hook="Maui.Popover">
    <Maui.Button.button
      :if={not @is_unstyled}
      id={"#{@id}-trigger"}
      variant={@variant}
      aria-haspopup="menu"
      aria-expanded="false"
      aria-controls={"#{@id}-listbox"}
      class={@class}
    >
      {render_slot(@inner_block)}
    </Maui.Button.button>
    <button
      :if={@is_unstyled}
      id={"#{@id}-trigger"}
      type="button"
      aria-haspopup="menu"
      aria-expanded="false"
      aria-controls={"#{@id}-listbox"}
      class={@class}
    >
      {render_slot(@inner_block)}
    </button>
    <.menu_content id={"#{@id}-listbox"} class={@content_class} is_unstyled={@is_unstyled}>
      <.menu_item
        :for={item <- @item}
        shortcut={Map.get(item, :shortcut)}
        variant={Map.get(item, :variant, "default")}
        href={Map.get(item, :href)}
        navigate={Map.get(item, :navigate)}
        patch={Map.get(item, :patch)}
        class={Map.get(item, :class)}
        is_unstyled={@is_unstyled}
      >
        {render_slot(item)}
      </.menu_item>
      {render_slot(@items)}
    </.menu_content>
  </div>
  """
end
```

**Step 3: Update menu_content to handle unstyled**

Modify `lib/maui/dropdown.ex:140-164`:

```elixir
attr :class, :string, default: ""
attr :rest, :global
attr :is_unstyled, :boolean, default: false
slot :inner_block

def menu_content(%{is_unstyled: is_unstyled} = assigns) do
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div
    aria-hidden="true"
    role="listbox"
    class={
      if @is_unstyled do
        [@class]
      else
        [
          "aria-hidden:hidden block bg-popover text-popover-foreground",
          "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "z-50  min-w-32 overflow-x-hidden overflow-y-auto rounded-md border border-border p-1 shadow-md",
          @class
        ]
      end
    }
    {@rest}
  >
    {render_slot(@inner_block)}
  </div>
  """
end
```

**Step 4: Update menu_item to handle unstyled**

Modify `lib/maui/dropdown.ex:166-207`:

```elixir
slot :inner_block
attr :shortcut, :string, default: nil
attr :variant, :string, default: "default", values: ["default", "destructive"]
attr :is_unstyled, :boolean, default: false
attr :class, :string, default: ""
attr :rest, :global, include: ~w(href navigate patch method download name value disabled)

def menu_item(%{rest: rest, is_unstyled: is_unstyled} = assigns) do
  base_class =
    if is_unstyled do
      []
    else
      [
        "aria-selected:bg-accent aria-selected:text-accent-foreground",
        "focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground",
        "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:text-destructive! [&_svg:not([class*='text-'])]:text-muted-foreground",
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
        "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
      ]
    end

  assigns = assign(assigns, class: base_class ++ [assigns[:class] || ""] |> Enum.filter(&(&1 != "")))

  if rest[:href] || rest[:navigate] || rest[:patch] do
    ~H"""
    <.link data-variant={@variant} role="menuitem" class={@class} {@rest}>
      {render_slot(@inner_block)}
      <.menu_shortcut :if={@shortcut != nil} is_unstyled={@is_unstyled}>
        {@shortcut}
      </.menu_shortcut>
    </.link>
    """
  else
    ~H"""
    <div
      data-variant={@variant}
      role="menuitem"
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
      <.menu_shortcut :if={@shortcut != nil} is_unstyled={@is_unstyled}>
        {@shortcut}
      </.menu_shortcut>
    </div>
    """
  end
end
```

**Step 5: Update menu_shortcut for unstyled**

Modify `lib/maui/dropdown.ex:209-222`:

```elixir
slot :inner_block
attr :rest, :global
attr :class, :string, default: ""
attr :is_unstyled, :boolean, default: false

def menu_shortcut(%{is_unstyled: is_unstyled} = assigns) do
  base_class =
    if is_unstyled do
      []
    else
      ["text-muted-foreground ml-auto text-xs tracking-widest"]
    end

  assigns = assign(assigns, class: base_class ++ [assigns[:class] || ""] |> Enum.filter(&(&1 != "")))

  ~H"""
  <span class={@class} {@rest}>
    {render_slot(@inner_block)}
  </span>
  """
end
```

**Step 6: Write tests**

Create `test/maui/dropdown_test.exs`:

```elixir
defmodule Maui.DropdownTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Dropdown

  describe "menu_button with variant='unstyled'" do
    test "renders unstyled button without default classes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.menu_button variant="unstyled" class="custom-btn">
        Open
        <:item class="custom-item">Profile</:item>
      </.menu_button>
      """)
      
      assert html =~ "custom-btn"
      assert html =~ "custom-item"
      refute html =~ "bg-secondary"
    end

    test "preserves ARIA attributes in unstyled mode" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.menu_button variant="unstyled">
        Open
        <:item>Profile</:item>
      </.menu_button>
      """)
      
      assert html =~ ~s(aria-haspopup="menu")
      assert html =~ ~s(role="listbox")
      assert html =~ ~s(role="menuitem")
    end

    test "menu_content accepts custom class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.menu_button variant="unstyled" content_class="my-menu">
        Open
        <:item>Profile</:item>
      </.menu_button>
      """)
      
      assert html =~ "my-menu"
    end
  end
end
```

**Step 7: Run tests**

Run: `mix test test/maui/dropdown_test.exs`
Expected: All tests pass

**Step 8: Commit**

```bash
git add lib/maui/dropdown.ex test/maui/dropdown_test.exs
git commit -m "feat(dropdown): add unstyled variant with slot classes"
```

---

## Task 3: Popover - Unstyled Variant

**Files:**
- Modify: `lib/maui/popover.ex`
- Test: `test/maui/popover_test.exs`

**Step 1: Add unstyled support to base popover**

Modify `lib/maui/popover.ex:92-94` (add variant attr):

```elixir
attr :id, :string, required: true
attr :variant, :string, default: "default", values: ["default", "unstyled"]
attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
attr :hook, :string, default: "Popover"
```

**Step 2: Update base function**

Modify `lib/maui/popover.ex:109-140`:

```elixir
def base(%{variant: variant} = assigns) do
  is_unstyled = variant == "unstyled"
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div id={@id} {@rest}>
    <%!-- Trigger --%>
    <button
      :for={t <- @trigger}
      type="button"
      class={if @is_unstyled, do: Map.get(t, :class, ""), else: Map.get(t, :class, "")}
      role={Map.get(t, :role, "combobox")}
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
      id={"#{@id}-popover"}
      role={Map.get(p, :role, "listbox")}
      aria-hidden="true"
      class={Map.get(p, :class, "")}
    >
      {render_slot(p)}
    </div>
  </div>
  """
end
```

**Step 3: Add variant to tooltip**

Modify `lib/maui/popover.ex:145-153`:

```elixir
attr :id, :string
attr :class, :string, default: ""
attr :variant, :string, default: "default", values: ["default", "unstyled"]
attr :placement, :string, values: ["top", "bottom", "left", "right"], default: "top"
slot :inner_block

slot :tooltip do
  attr :class, :string
end
```

**Step 4: Update tooltip function**

Modify `lib/maui/popover.ex:154-196`:

```elixir
def tooltip(%{variant: variant} = assigns) do
  assigns = assign_new(assigns, :id, fn -> "tooltip#{System.unique_integer()}" end)
  is_unstyled = variant == "unstyled"
  assigns = assign(assigns, :is_unstyled, is_unstyled)

  ~H"""
  <div
    id={@id}
    class="w-fit group"
    data-placement={@placement}
    phx-hook="Maui.Tooltip"
  >
    {render_slot(@inner_block)}

    <div
      :if={@tooltip != []}
      role="tooltip"
      id={"#{@id}-tooltip"}
      aria-hidden="true"
      data-placement={@placement}
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "bg-foreground text-background",
            "duration-100 transition ease-in transform",
            "data-[placement=top]:translate-y-0 data-[placement=top]:aria-hidden:translate-y-2",
            "data-[placement=bottom]:translate-y-0 data-[placement=bottom]:aria-hidden:-translate-y-2",
            "data-[placement=right]:translate-x-0 data-[placement=right]:aria-hidden:-translate-x-2",
            "data-[placement=left]:translate-x-0 data-[placement=left]:aria-hidden:translate-x-2",
            "opacity-100 aria-hidden:opacity-0",
            "aria-hidden:pointer-events-none",
            "invisible not-aria-hidden:visible",
            "z-50 w-fit rounded-md px-3 py-1.5 text-sm text-balance",
            @class
          ]
        end
      }
    >
      {render_slot(@tooltip)}

      <div
        :if={not @is_unstyled}
        data-arrow
        class="absolute bg-foreground fill-foreground z-[-1] size-2.5 rotate-45 rounded-[2px]"
      >
      </div>
    </div>
  </div>
  """
end
```

**Step 5: Write tests**

Create `test/maui/popover_test.exs`:

```elixir
defmodule Maui.PopoverTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Popover

  describe "base popover with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.popover_base id="test" variant="unstyled" phx-hook="Maui.Popover">
        <:trigger class="my-trigger">Click</:trigger>
        <:popup class="my-popup">Content</:popup>
      </.popover_base>
      """)
      
      assert html =~ "my-trigger"
      assert html =~ "my-popup"
    end

    test "preserves ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.popover_base id="test" variant="unstyled" phx-hook="Maui.Popover">
        <:trigger>Click</:trigger>
        <:popup>Content</:popup>
      </.popover_base>
      """)
      
      assert html =~ ~s(aria-haspopup="listbox")
      assert html =~ ~s(role="listbox")
    end
  end

  describe "tooltip with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.tooltip variant="unstyled" class="my-tooltip">
        <span>Hover me</span>
        <:tooltip>Tooltip text</:tooltip>
      </.tooltip>
      """)
      
      assert html =~ "my-tooltip"
      refute html =~ "bg-foreground"
    end

    test "hides arrow in unstyled mode" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.tooltip variant="unstyled">
        <span>Hover</span>
        <:tooltip>Text</:tooltip>
      </.tooltip>
      """)
      
      refute html =~ "data-arrow"
    end
  end
end
```

**Step 6: Run tests**

Run: `mix test test/maui/popover_test.exs`
Expected: All tests pass

**Step 7: Commit**

```bash
git add lib/maui/popover.ex test/maui/popover_test.exs
git commit -m "feat(popover): add unstyled variant support"
```

---

## Task 4: Dialog - Unstyled Variant

**Files:**
- Modify: `lib/maui/dialog.ex`
- Test: `test/maui/dialog_test.exs`

**Step 1: Add variant to dialog**

Modify `lib/maui/dialog.ex:174-179`:

```elixir
attr :id, :string, required: true
attr :on_cancel, JS, default: %JS{}
attr :alert, :boolean, default: false
attr :show, :boolean, default: false, doc: "Control dialog visibility from server"
attr :size, :string, values: ["sm", "md", "lg", "xl"], default: "md"
attr :variant, :string, default: "default", values: ["default", "unstyled"]
attr :class, :string, default: ""
```

**Step 2: Update dialog function**

Modify `lib/maui/dialog.ex:184-244`:

```elixir
def dialog(%{variant: variant} = assigns) do
  is_unstyled = variant == "unstyled"
  
  size_class =
    if is_unstyled do
      ""
    else
      case assigns[:size] do
        "sm" -> "sm:max-w-sm"
        "md" -> "md:max-w-md"
        "lg" -> "lg:max-w-lg"
        "xl" -> "xl:max-w-xl"
      end
    end

  cancel_action =
    if assigns[:show] do
      assigns[:on_cancel]
    else
      JS.exec(assigns[:on_cancel], "phx-remove")
    end

  assigns =
    assigns
    |> assign(:size_class, size_class)
    |> assign(:cancel_action, cancel_action)
    |> assign(:is_unstyled, is_unstyled)

  ~H"""
  <div
    id={@id}
    phx-window-keydown={JS.exec("data-cancel")}
    phx-key="escape"
    phx-remove={hide_dialog(@id)}
    data-cancel={@cancel_action}
  >
    {render_slot(@trigger, %{
      "phx-click": show_dialog(@id)
    })}
    <.backdrop
      id={"#{@id}-backdrop"}
      hidden={not @show}
      class={if @is_unstyled, do: @class, else: ""}
      phx-click={if @alert, do: nil, else: JS.exec("data-cancel", to: "##{@id}")}
    />

    <%= if @content != [] do %>
      {render_slot(
        @content,
        {%{id: "#{@id}-content", hidden: not @show},
         %{hide: JS.exec("data-cancel", to: "##{@id}"), show: show_dialog(@id)}}
      )}
    <% end %>

    <.content
      :if={@content == []}
      role={if @alert, do: "alertdialog", else: "dialog"}
      aria-modal="true"
      class={[@size_class, if(@is_unstyled, do: @class, else: "")]}
      id={"#{@id}-content"}
      hidden={not @show}
      is_unstyled={@is_unstyled}
    >
      {render_slot(@inner_block, %{
        hide: JS.exec("data-cancel", to: "##{@id}"),
        show: show_dialog(@id)
      })}
    </.content>
  </div>
  """
end
```

**Step 3: Update backdrop for unstyled**

Modify `lib/maui/dialog.ex:133-149`:

```elixir
attr :class, :string, default: ""
attr :rest, :global
attr :is_unstyled, :boolean, default: false
slot :inner_block

def backdrop(%{is_unstyled: is_unstyled} = assigns) do
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div
    class={
      if @is_unstyled do
        [@class]
      else
        [
          "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 fixed inset-0 z-50 bg-black/50",
          @class
        ]
      end
    }
    {@rest}
  >
    {render_slot(@inner_block)}
  </div>
  """
end
```

**Step 4: Update content for unstyled**

Modify `lib/maui/dialog.ex:151-172`:

```elixir
attr :id, :string, required: true
attr :class, :string, default: ""
attr :rest, :global
attr :is_unstyled, :boolean, default: false
slot :inner_block

def content(%{is_unstyled: is_unstyled} = assigns) do
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div
    id={@id}
    class={
      if @is_unstyled do
        [@class]
      else
        [
          "not-[hidden]:animate-in [hidden]:animate-out [hidden]:fade-out-0 not-[hidden]:fade-in-0 [hidden]:zoom-out-95 not-[hidden]:zoom-in-95",
          "bg-background fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-lg",
          @class
        ]
      end
    }
    {@rest}
  >
    <.focus_wrap id={"#{@id}-focus"}>
      {render_slot(@inner_block)}
    </.focus_wrap>
  </div>
  """
end
```

**Step 5: Write tests**

Create `test/maui/dialog_test.exs`:

```elixir
defmodule Maui.DialogTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Dialog

  describe "dialog with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.dialog id="test" variant="unstyled" class="my-dialog">
        <:trigger :let={attr}>
          <button {attr}>Open</button>
        </:trigger>
        <p>Content</p>
      </.dialog>
      """)
      
      assert html =~ "my-dialog"
      refute html =~ "bg-background"
      refute html =~ "fixed"
    end

    test "preserves ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.dialog id="test" variant="unstyled">
        <:trigger :let={attr}>
          <button {attr}>Open</button>
        </:trigger>
        <p>Content</p>
      </.dialog>
      """)
      
      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
    end

    test "custom backdrop class" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.dialog id="test" variant="unstyled" class="backdrop-custom">
        <:trigger :let={attr}>
          <button {attr}>Open</button>
        </:trigger>
        <p>Content</p>
      </.dialog>
      """)
      
      assert html =~ "backdrop-custom"
    end
  end
end
```

**Step 6: Run tests**

Run: `mix test test/maui/dialog_test.exs`
Expected: All tests pass

**Step 7: Commit**

```bash
git add lib/maui/dialog.ex test/maui/dialog_test.exs
git commit -m "feat(dialog): add unstyled variant support"
```

---

## Task 5: Select - Unstyled Variant

**Files:**
- Modify: `lib/maui/select.ex`
- Test: `test/maui/select_test.exs`

**Step 1: Add variant attribute**

Modify `lib/maui/select.ex:99-106`:

```elixir
attr :id, :string, default: nil
attr :name, :string, default: nil
attr :value, :string, default: nil
attr :placeholder, :string, default: "Select an item"
attr :options, :list, default: []
attr :searchable, :boolean, default: false
attr :class, :string, default: "w-fit"
attr :label, :string, default: nil
attr :variant, :string, default: "default", values: ["default", "unstyled"]
```

**Step 2: Update select function for unstyled**

Modify `lib/maui/select.ex:155-203`:

```elixir
def select(%{variant: variant} = assigns) do
  assigns = map_field(assigns)
  is_unstyled = variant == "unstyled"
  assigns = assign(assigns, :is_unstyled, is_unstyled)

  ~H"""
  <div
    id={@id}
    data-value={@value}
    phx-hook="Maui.Select"
    class="relative"
  >
    <input type="hidden" name={@name} value={@value} />
    <button
      type="button"
      role="combobox"
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "border-input data-placeholder:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 dark:hover:bg-input/50 flex items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring [3px] disabled:cursor-not-allowed disabled:opacity-50 data-[size=default]:h-9 data-[size=sm]:h-8 *:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-2 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
            @class
          ]
        end
      }
    >
      <span data-maui="selected-label">
        {@placeholder}
      </span>
      <.select_icon :if={not @is_unstyled} class="ml-2 h-4 w-4 shrink-0 opacity-50" />
    </button>

    <div
      role="listbox"
      aria-hidden="true"
      class={
        if @is_unstyled do
          [@class]
        else
          [
            "aria-hidden:hidden block bg-popover text-popover-foreground",
            "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
            "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
            "z-50 min-w-52 overflow-x-hidden overflow-y-auto rounded-md border border-border shadow-md",
            "max-h-(--radix-dropdown-menu-content-available-height) origin-(--radix-dropdown-menu-content-transform-origin)"
          ]
        end
      }
    >
      {render_slot(@header)}

      <.select_search :if={@searchable and not @is_unstyled} />

      <div data-maui="menu-items">
        {render_slot(@inner_block)}
      </div>

      {render_slot(@footer)}
    </div>
  </div>
  """
end
```

**Step 3: Update select_item for unstyled**

Modify `lib/maui/select.ex:239-258`:

```elixir
attr :value, :string, required: true
attr :class, :string, default: ""
attr :variant, :string, default: "default", values: ["default", "unstyled"]
slot :inner_block

def select_item(%{variant: variant} = assigns) do
  is_unstyled = variant == "unstyled"
  
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div
    role="menuitem"
    data-value={@value}
    class={
      if @is_unstyled do
        [@class]
      else
        [
          "aria-hidden:hidden",
          "focus:bg-accent focus:text-accent-foreground hover:bg-accent hover:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground",
          "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10 dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:*:[svg]:!text-destructive [&_svg:not([class*='text-'])]:text-muted-foreground",
          "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
          "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
          @class
        ]
      end
    }
  >
    {render_slot(@inner_block)}
  </div>
  """
end
```

**Step 4: Write tests**

Create `test/maui/select_test.exs`:

```elixir
defmodule Maui.SelectTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Select

  describe "select with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.select id="test" variant="unstyled" class="my-select">
        <.select_item value="a" class="my-item">Option A</.select_item>
      </.select>
      """)
      
      assert html =~ "my-select"
      assert html =~ "my-item"
      refute html =~ "border-input"
    end

    test "preserves ARIA attributes" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.select id="test" variant="unstyled">
        <.select_item value="a">Option A</.select_item>
      </.select>
      """)
      
      assert html =~ ~s(role="combobox")
      assert html =~ ~s(role="listbox")
      assert html =~ ~s(role="menuitem")
    end

    test "hides default icon in unstyled mode" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.select id="test" variant="unstyled">
        <.select_item value="a">Option A</.select_item>
      </.select>
      """)
      
      refute html =~ "lucide lucide-chevron"
    end
  end
end
```

**Step 5: Run tests**

Run: `mix test test/maui/select_test.exs`
Expected: All tests pass

**Step 6: Commit**

```bash
git add lib/maui/select.ex test/maui/select_test.exs
git commit -m "feat(select): add unstyled variant support"
```

---

## Task 6: Alert - Unstyled Variant

**Files:**
- Modify: `lib/maui/alert.ex:70-71`
- Test: `test/maui/alert_test.exs`

**Step 1: Add unstyled to variant values**

Modify `lib/maui/alert.ex:70-71`:

```elixir
attr :class, :string, default: ""
attr :variant, :string, values: ["default", "destructive", "unstyled"], default: "default"
```

**Step 2: Update alert function**

Modify `lib/maui/alert.ex:78-109`:

```elixir
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

  assigns = assign(assigns, variant_class: variant_class, is_unstyled: is_unstyled)

  ~H"""
  <div class={
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
  }>
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
```

**Step 3: Update alert_title for unstyled**

Modify `lib/maui/alert.ex:114-123`:

```elixir
attr :class, :string, default: ""
attr :is_unstyled, :boolean, default: false
slot :inner_block

def alert_title(%{is_unstyled: is_unstyled} = assigns) do
  assigns = assign(assigns, :is_unstyled, is_unstyled)
  
  ~H"""
  <div class={if @is_unstyled, do: [@class], else: ["col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight", @class]}>
    {render_slot(@inner_block)}
  </div>
  """
end
```

**Step 4: Update alert_description for unstyled**

Modify `lib/maui/alert.ex:128-144`:

```elixir
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
```

**Step 5: Write tests**

Create `test/maui/alert_test.exs`:

```elixir
defmodule Maui.AlertTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import Maui.Alert

  describe "alert with variant='unstyled'" do
    test "renders without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.alert variant="unstyled" class="my-alert">
        <:title>Title</:title>
        <:description>Description</:description>
      </.alert>
      """)
      
      assert html =~ "my-alert"
      refute html =~ "bg-card"
      refute html =~ "rounded-lg"
    end

    test "renders title and description without default styles" do
      assigns = %{}
      
      html = rendered_to_string(~H"""
      <.alert variant="unstyled">
        <:title class="my-title">Title</:title>
        <:description class="my-desc">Description</:description>
      </.alert>
      """)
      
      assert html =~ "my-title"
      assert html =~ "my-desc"
    end
  end
end
```

**Step 6: Run tests**

Run: `mix test test/maui/alert_test.exs`
Expected: All tests pass

**Step 7: Commit**

```bash
git add lib/maui/alert.ex test/maui/alert_test.exs
git commit -m "feat(alert): add unstyled variant support"
```

---

## Task 7: Update Documentation

**Files:**
- Create: `guides/headless-usage.md`
- Modify: `README.md`
- Modify: `guides/usage.md`

**Step 1: Create headless usage guide**

Create `guides/headless-usage.md`:

```markdown
# Headless Component Usage

Maui supports three levels of component usage, from fully styled to completely custom.

## Level 1: Low-level Hooks (Direct Floating UI)

For maximum control, use the low-level hooks directly with Floating UI:

```elixir
<.popover_base phx-hook="Maui.Popover" data-placement="bottom">
  <.button class="your-custom-classes">Trigger</.button>
  <:popup class="your-popup-classes">
    Custom content with full control
  </:popup>
</.popover_base>
```

### Available Hooks

- `Maui.Popover` - Popover/dropdown positioning
- `Maui.Tooltip` - Tooltip positioning
- `Maui.Select` - Select dropdown with search

### Hook Configuration

Hooks accept data attributes for configuration:

```elixir
<.popover_base 
  phx-hook="Maui.Popover"
  data-placement="top"
  data-trigger="hover"
  data-strategy="fixed"
>
  ...
</.popover_base>
```

## Level 2: Unstyled Components

Use `variant="unstyled"` to get component behavior without styling:

```elixir
<.menu_button variant="unstyled" class="px-4 py-2 bg-blue-500 text-white">
  Open Menu
  <:item class="px-4 py-2 hover:bg-gray-100">Profile</:item>
  <:item class="px-4 py-2 hover:bg-gray-100">Settings</:item>
</.menu_button>
```

### Available Unstyled Components

All components support `variant="unstyled"`:

- `button`
- `menu_button`
- `tooltip`
- `dialog`
- `select`
- `alert`

### Slot Classes

Each slot accepts a `class` attribute:

```elixir
<.menu_button variant="unstyled">
  Open
  <:item class="my-item-class">Item 1</:item>
</.menu_button>

<.dialog variant="unstyled" class="my-dialog">
  <:trigger :let={attr}>
    <button {attr} class="my-trigger">Open</button>
  </:trigger>
  <p class="my-content">Dialog content</p>
</.dialog>
```

## Level 3: Styled Components

Default styled components with Tailwind classes:

```elixir
<.menu_button variant="secondary" class="w-full">
  Open Menu
  <:item>Profile</:item>
</.menu_button>
```

### Customizing Styled Components

Use `class` to extend or override styles:

```elixir
<.button variant="secondary" class="w-full !bg-red-500">
  Full Width Red Button
</.button>
```

## Migration Guide

### From Styled to Unstyled

1. Add `variant="unstyled"` to component
2. Add custom classes to component and slots
3. Maintain any `phx-*` attributes for interactivity

```elixir
# Before
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>

# After
<.menu_button variant="unstyled" class="btn btn-secondary">
  Open
  <:item class="menu-item">Profile</:item>
</.menu_button>
```

### CSS Framework Compatibility

Unstyled components work with any CSS framework:

**Bootstrap:**
```elixir
<.button variant="unstyled" class="btn btn-primary">
  Bootstrap Button
</.button>
```

**Tailwind Custom:**
```elixir
<.button variant="unstyled" class="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500">
  Custom Gradient
</.button>
```

**CSS Modules:**
```elixir
<.button variant="unstyled" class={@styles.button}>
  CSS Module Button
</.button>
```

## ARIA and Accessibility

Unstyled components preserve all ARIA attributes:

```elixir
<.menu_button variant="unstyled">
  <!-- Still has aria-haspopup, aria-expanded, role="menu", etc. -->
  Open
  <:item>Profile</:item>
</.menu_button>
```

All three usage levels maintain proper accessibility.
```

**Step 2: Update README with headless info**

Modify `README.md` to add headless section after introduction:

```markdown
## Headless Components

Maui supports three usage levels:

**Level 1: Low-level Hooks** - Direct Floating UI access
```elixir
<.popover_base phx-hook="Maui.Popover">
  <.button>Trigger</.button>
  <:popup class="custom">Content</:popup>
</.popover_base>
```

**Level 2: Unstyled Components** - Behavior without styles
```elixir
<.menu_button variant="unstyled" class="my-btn">
  Open
  <:item class="my-item">Profile</:item>
</.menu_button>
```

**Level 3: Styled Components** - Ready-to-use defaults
```elixir
<.menu_button variant="secondary">
  Open
  <:item>Profile</:item>
</.menu_button>
```

See [Headless Usage Guide](guides/headless-usage.md) for details.
```

**Step 3: Update component docs with unstyled examples**

For each component file, add unstyled examples to `@moduledoc`:

Example for `lib/maui/button.ex`:

```elixir
@moduledoc """
A versatile button component with multiple variants and sizes.

## Basic Usage

    <.button>Click me</.button>

## Unstyled Variant

Use `variant="unstyled"` for complete control:

    <.button variant="unstyled" class="px-4 py-2 bg-blue-500 text-white rounded">
      Custom Button
    </.button>

## Variants
...
```

**Step 4: Commit documentation**

```bash
git add guides/headless-usage.md README.md lib/maui/*.ex
git commit -m "docs: add headless component usage guide and examples"
```

---

## Task 8: Update Mix.exs Version

**Files:**
- Modify: `mix.exs:6`

**Step 1: Bump version**

Modify `mix.exs:6`:

```elixir
version: "1.0.0-alpha.10",
```

**Step 2: Commit**

```bash
git add mix.exs
git commit -m "chore: bump version to 1.0.0-alpha.10"
```

---

## Task 9: Run Full Test Suite

**Step 1: Run all tests**

Run: `mix test`
Expected: All tests pass

**Step 2: Run format check**

Run: `mix format --check-formatted`
Expected: All files formatted

**Step 3: Run compilation**

Run: `mix compile`
Expected: No warnings

**Step 4: Generate docs**

Run: `mix docs`
Expected: Documentation generated successfully

---

## Task 10: Final Commit

**Step 1: Create summary commit**

```bash
git add .
git commit -m "feat: add headless component library support

- Add variant='unstyled' to all components
- Preserve ARIA attributes in unstyled mode
- Support slot class attributes
- Add low-level floating-ui hook access
- Add comprehensive documentation
- Add test coverage for unstyled variants

Components updated:
- Button
- Dropdown/MenuButton
- Popover/Tooltip
- Dialog
- Select
- Alert

BREAKING CHANGE: None - fully backward compatible"
```

---

## Verification Commands

After implementation, verify:

```bash
# Run all tests
mix test

# Check formatting
mix format --check-formatted

# Check compilation
mix compile --warnings-as-errors

# Generate documentation
mix docs

# Verify documentation structure
ls doc/
```

## Expected File Structure

```
maui/
├── lib/maui/
│   ├── button.ex (updated)
│   ├── dropdown.ex (updated)
│   ├── popover.ex (updated)
│   ├── dialog.ex (updated)
│   ├── select.ex (updated)
│   └── alert.ex (updated)
├── test/maui/
│   ├── button_test.exs (new)
│   ├── dropdown_test.exs (new)
│   ├── popover_test.exs (new)
│   ├── dialog_test.exs (new)
│   ├── select_test.exs (new)
│   └── alert_test.exs (new)
├── guides/
│   ├── usage.md (updated)
│   └── headless-usage.md (new)
├── docs/plans/
│   └── 2026-03-07-headless-component-library.md (this file)
└── README.md (updated)
```

## Architecture Benefits

1. **Backward Compatible**: No breaking changes to existing API
2. **Progressive Enhancement**: Users can adopt headless gradually
3. **Framework Agnostic**: Works with any CSS framework
4. **Accessible**: ARIA attributes preserved across all modes
5. **Testable**: Each component has comprehensive test coverage
6. **Documented**: Clear examples for each usage level

## Future Enhancements

Potential future additions:
- Custom theme configuration via CSS variables
- Animation customization hooks
- Additional floating-ui middleware options
- Server-side rendering optimizations