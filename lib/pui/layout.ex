defmodule PUI.Layout do
  @moduledoc """
  Reusable application shell primitives for documentation sites, dashboards, and
  other two-pane LiveView layouts.

  The layout API is split into small components so applications can compose
  their own shell without inheriting opinionated navigation data structures.

  ## Basic Usage

      <.app_layout id="docs-shell">
        <:sidebar>
          <.sidebar>
            <:header>
              <div class="px-4 py-3 font-semibold">PUI</div>
            </:header>

            <nav class="p-3">
              <.sidebar_menu_item title="Getting Started" icon="hero-rocket-launch" href="/docs" />
            </nav>
          </.sidebar>
        </:sidebar>

        <:header>
          <.content_header shell_id="docs-shell" breadcrumb_current="Getting Started" />
        </:header>

        Content goes here.
      </.app_layout>

  ## Collapsible Navigation

  Use `collapsible={true}` on `sidebar_menu_item/1` when an item owns nested
  links. The submenu state is handled by the bundled `PUI.Sidebar` hook.

      <.sidebar_menu_item
        title="Components"
        icon="hero-squares-2x2"
        collapsible
        expanded
      >
        <:subitem>
          <.link href="/docs/button" class="block rounded-md px-2 py-1.5 text-sm">Button</.link>
        </:subitem>
      </.sidebar_menu_item>

  ## Components

  | Component | Description |
  |-----------|-------------|
  | `app_layout/1` | Root shell with collapsible sidebar state |
  | `sidebar/1` | Sidebar surface with header and footer slots |
  | `sidebar_menu_item/1` | Sidebar link row with optional collapsible submenu |
  | `content_header/1` | Sticky content header with sidebar toggle and breadcrumbs |
  """

  use Phoenix.Component
  import PUI.Popover, only: [tooltip: 1]
  import PUI.Dropdown, only: [menu_button: 1]

  @doc """
  Renders a two-pane application shell.

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | `"app-layout"` | Shell DOM id, used by `content_header/1` toggle |
  | `class` | `string` | `""` | Additional classes for the root shell |
  | `content_class` | `string` | `"w-full px-4 py-4"` | Classes for the scrollable main content element |
  | `collapsed` | `boolean` | `false` | Initial sidebar collapsed state rendered by the server |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `sidebar` | Yes | Sidebar content, usually `sidebar/1` |
  | `header` | No | Sticky header content, usually `content_header/1` |
  | `inner_block` | Yes | Main page content |
  """
  attr :id, :string, default: "app-layout"
  attr :class, :string, default: ""
  attr :content_class, :string, default: "w-full px-4 py-4"
  attr :collapsed, :boolean, default: false

  slot :sidebar, required: true
  slot :header
  slot :inner_block, required: true

  def app_layout(assigns) do
    ~H"""
    <div
      id={@id}
      data-collapsed={if @collapsed, do: "true", else: "false"}
      class={[
        "group/pui-layout flex h-dvh overflow-hidden bg-background text-foreground",
        @class
      ]}
    >
      <.sidebar_controller id={"#{@id}-sidebar-controller"} shell_id={@id} />

      {render_slot(@sidebar)}

      <section class="flex min-w-0 flex-1 flex-col overflow-hidden">
        <%= if @header != [] do %>
          {render_slot(@header)}
        <% end %>

        <main class={["min-h-0 flex-1 overflow-x-hidden overflow-y-auto", @content_class]}>
          {render_slot(@inner_block)}
        </main>
      </section>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :shell_id, :string, required: true

  defp sidebar_controller(assigns) do
    ~H"""
    <span
      id={@id}
      phx-hook="PUI.Sidebar"
      phx-update="ignore"
      data-shell={@shell_id}
      class="hidden"
    >
    </span>
    """
  end

  @doc """
  Renders a collapsible sidebar surface.

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | `"app-sidebar"` | Sidebar DOM id |
  | `class` | `string` | `""` | Additional classes for the sidebar |
  | `expanded_width_class` | `string` | `"w-72"` | Width class when the shell is expanded |
  | `collapsed_width_class` | `string` | `"group-data-[collapsed=true]/pui-layout:w-12"` | Width class when collapsed |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `header` | No | Logo, workspace switcher, or sidebar title |
  | `inner_block` | Yes | Sidebar navigation/content |
  | `footer` | No | Account controls or secondary actions |
  """
  attr :id, :string, default: "app-sidebar"
  attr :class, :string, default: ""
  attr :expanded_width_class, :string, default: "w-72"
  attr :collapsed_width_class, :string, default: "group-data-[collapsed=true]/pui-layout:w-12"

  slot :header
  slot :inner_block, required: true
  slot :footer

  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      class={[
        "relative flex h-full shrink-0 flex-col overflow-hidden border-r border-border/80 bg-muted/20 transition-[width] duration-200 ease-out",
        @expanded_width_class,
        @collapsed_width_class,
        @class
      ]}
    >
      <%= if @header != [] do %>
        {render_slot(@header)}
      <% end %>

      <div class="min-h-0 flex-1 overflow-y-auto">
        {render_slot(@inner_block)}
      </div>

      <%= if @footer != [] do %>
        {render_slot(@footer)}
      <% end %>
    </aside>
    """
  end

  @doc """
  Renders a sidebar item as a link or as a collapsible submenu trigger.

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | derived from `title` | Stable DOM id |
  | `title` | `string` | required | Visible item label and link title |
  | `icon` | `string` | required | Heroicon class, such as `"hero-home"` |
  | `navigate` | `string` | `nil` | LiveView navigation target |
  | `href` | `string` | `nil` | Link href |
  | `patch` | `string` | `nil` | LiveView patch target |
  | `collapsible` | `boolean` | `false` | Render a submenu trigger instead of a link |
  | `expanded` | `boolean` | `false` | Initial submenu state |
  | `current` | `boolean` | `false` | Applies active item styling |
  | `class` | `string` | `""` | Additional classes for the row |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `trailing` | No | Badge, count, or secondary row content |
  | `subitem` | No | Repeated submenu rows for collapsible items |
  """
  attr :id, :string, default: nil
  attr :title, :string, required: true
  attr :icon, :string, required: true
  attr :navigate, :string, default: nil
  attr :href, :string, default: nil
  attr :patch, :string, default: nil
  attr :collapsible, :boolean, default: false
  attr :expanded, :boolean, default: false
  attr :class, :string, default: ""
  attr :current, :boolean, default: false

  slot :trailing
  slot :subitem

  def sidebar_menu_item(assigns) do
    assigns =
      assign(
        assigns,
        :id,
        assigns.id ||
          assigns.title
          |> String.downcase()
          |> String.replace(~r/[^a-z0-9]+/, "-")
          |> String.trim("-")
          |> then(&"sidebar-item-#{&1}")
      )

    ~H"""
    <div
      :if={@collapsible}
      id={"#{@id}-collapsible"}
      phx-hook="PUI.Sidebar"
      data-target={"#{@id}-submenu"}
      data-expanded={to_string(@expanded)}
      class="space-y-1"
    >
      <button
        id={"#{@id}-trigger"}
        type="button"
        aria-controls={"#{@id}-submenu"}
        aria-expanded={to_string(@expanded)}
        title={@title}
        class={sidebar_menu_item_class(@current, @class) <> " w-full group-data-[collapsed=true]/pui-layout:hidden"}
      >
        <span class="flex h-4 w-4 shrink-0 items-center justify-center">
          <PUI.Container.icon name={@icon} class="h-4 w-4 shrink-0" />
        </span>
        <span class="truncate">{@title}</span>
        <%= if @trailing != [] do %>
          <span class="ml-auto">
            {render_slot(@trailing)}
          </span>
        <% end %>
        <PUI.Container.icon
          name="hero-chevron-down"
          class="sidebar-collapsible-chevron ml-auto h-4 w-4 shrink-0 transition-transform duration-200 data-[expanded=true]:rotate-180"
          data-expanded={to_string(@expanded)}
        />
      </button>

      <.menu_button
        id={"#{@id}-collapsed-menu"}
        trigger="hover"
        variant="unstyled"
        placement="right-start"
        wrapper_class="hidden group-data-[collapsed=true]/pui-layout:block"
        class={sidebar_menu_item_class(@current, @class)}
        content_class="z-[60] min-w-48 rounded-md border border-border bg-background p-1 shadow-lg"
      >
        <span class="flex h-4 w-4 shrink-0 items-center justify-center">
          <PUI.Container.icon name={@icon} class="h-4 w-4 shrink-0" />
        </span>
        <span class="sr-only">{@title}</span>
        <:items>
          <div class="space-y-1">
            <%= for subitem <- @subitem do %>
              {render_slot(subitem)}
            <% end %>
          </div>
        </:items>
      </.menu_button>

      <div
        id={"#{@id}-submenu"}
        aria-hidden={to_string(!@expanded)}
        data-expanded={to_string(@expanded)}
        class={[
          "ml-5 space-y-1 overflow-hidden border-l border-border pl-3 transition-[max-height,opacity] duration-200 ease-out",
          "data-[expanded=true]:max-h-96 data-[expanded=true]:opacity-100 data-[expanded=false]:max-h-0 data-[expanded=false]:opacity-0",
          "group-data-[collapsed=true]/pui-layout:hidden"
        ]}
      >
        <%= for subitem <- @subitem do %>
          {render_slot(subitem)}
        <% end %>
      </div>
    </div>

    <.tooltip
      :if={!@collapsible}
      id={"#{@id}-tooltip"}
      placement="right"
      container_class="w-full"
      class="hidden group-data-[collapsed=true]/pui-layout:block"
    >
      <.link
        id={@id}
        navigate={@navigate}
        href={@href}
        patch={@patch}
        title={@title}
        class={sidebar_menu_item_class(@current, @class)}
      >
        <span class="flex h-4 w-4 shrink-0 items-center justify-center">
          <PUI.Container.icon name={@icon} class="h-4 w-4 shrink-0" />
        </span>
        <span class="truncate group-data-[collapsed=true]/pui-layout:hidden">{@title}</span>
        <%= if @trailing != [] do %>
          <span class="ml-auto group-data-[collapsed=true]/pui-layout:hidden">
            {render_slot(@trailing)}
          </span>
        <% end %>
      </.link>

      <:tooltip>{@title}</:tooltip>
    </.tooltip>
    """
  end

  defp sidebar_menu_item_class(current, class) do
    [
      "group flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors",
      "text-foreground/75 hover:bg-accent hover:text-accent-foreground",
      "group-data-[collapsed=true]/pui-layout:mx-auto group-data-[collapsed=true]/pui-layout:h-10 group-data-[collapsed=true]/pui-layout:w-10 group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:gap-0 group-data-[collapsed=true]/pui-layout:px-0 group-data-[collapsed=true]/pui-layout:py-0",
      current && "bg-primary/10 text-primary",
      class
    ]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
  end

  @doc """
  Renders a sticky shell header with a sidebar toggle and breadcrumb.

  ## Attributes

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `shell_id` | `string` | `"app-layout"` | Target shell id for collapse toggling |
  | `class` | `string` | `""` | Additional classes for the header |
  | `toggle_class` | `string` | `""` | Additional classes for the toggle button |
  | `title` | `string` | `nil` | Small eyebrow text above the breadcrumb |
  | `breadcrumb_parent` | `string` | `nil` | Optional parent breadcrumb |
  | `breadcrumb_current` | `string` | required | Current page breadcrumb |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `right_actions` | No | Right-aligned buttons, menus, or theme controls |
  """
  attr :shell_id, :string, default: "app-layout"
  attr :class, :string, default: ""
  attr :toggle_class, :string, default: ""
  attr :title, :string, default: nil
  attr :breadcrumb_parent, :string, default: nil
  attr :breadcrumb_current, :string, required: true

  slot :right_actions

  def content_header(assigns) do
    ~H"""
    <header class={[
      "sticky top-0 z-20 flex h-16 items-center justify-between gap-4 border-b border-border bg-background/95 px-4 backdrop-blur supports-[backdrop-filter]:bg-background/75",
      @class
    ]}>
      <div class="flex min-w-0 flex-1 items-center gap-3">
        <button
          id={"#{@shell_id}-sidebar-collapse-toggle"}
          type="button"
          class={[
            "grid h-9 w-9 shrink-0 place-items-center rounded-lg border border-transparent text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground",
            @toggle_class
          ]}
          title="Toggle sidebar"
          aria-label="Toggle sidebar"
        >
          <PUI.Container.icon name="hero-bars-3" class="h-4 w-4" />
        </button>

        <div class="min-w-0">
          <%= if @title do %>
            <p class="text-xs font-semibold uppercase tracking-[0.18em] text-muted-foreground">
              {@title}
            </p>
          <% end %>
          <nav aria-label="Breadcrumb" class="min-w-0">
            <ol class="flex min-w-0 items-center gap-2 text-sm">
              <li :if={@breadcrumb_parent} class="hidden truncate text-muted-foreground md:block">
                {@breadcrumb_parent}
              </li>
              <li :if={@breadcrumb_parent} class="hidden text-muted-foreground md:block">/</li>
              <li class="truncate font-medium text-foreground">{@breadcrumb_current}</li>
            </ol>
          </nav>
        </div>
      </div>

      <%= if @right_actions != [] do %>
        <div class="flex items-center gap-2">
          {render_slot(@right_actions)}
        </div>
      <% end %>
    </header>
    """
  end
end
