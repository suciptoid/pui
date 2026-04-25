defmodule AppWeb.Live.LayoutAppLive do
  @moduledoc """
  Full-page demo for the reusable PUI application layout shell.
  """
  use AppWeb, :live_view
  use PUI

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "App Layout Demo")
     |> assign(:flash_position, "top-right")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.app_layout id="demo-app-shell" content_class="bg-muted/20 p-0">
      <:sidebar>
        <.sidebar id="demo-app-sidebar" expanded_width_class="w-72">
          <:header>
            <div class="flex h-16 items-center border-b border-border px-4 group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:px-0">
              <.link
                navigate={~p"/docs/layout"}
                class="flex min-w-0 items-center gap-3 group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:gap-0"
              >
                <div class="grid h-10 w-10 shrink-0 place-items-center rounded-md bg-primary text-primary-foreground shadow-sm">
                  <.icon name="hero-command-line" class="size-5" />
                </div>
                <div class="min-w-0 group-data-[collapsed=true]/pui-layout:hidden">
                  <p class="truncate text-sm font-semibold text-foreground">PUI Console</p>
                  <p class="truncate text-xs text-muted-foreground">Reusable app shell</p>
                </div>
              </.link>
            </div>
          </:header>

          <nav class="flex flex-col gap-3 p-3 group-data-[collapsed=true]/pui-layout:gap-0 group-data-[collapsed=true]/pui-layout:px-0 group-data-[collapsed=true]/pui-layout:py-0">
            <div class="flex flex-col gap-1 group-data-[collapsed=true]/pui-layout:gap-0">
              <p class="px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden">
                Workspace
              </p>
              <.sidebar_menu_item title="Overview" icon="hero-home" href="#" current />
              <.sidebar_menu_item title="Activity" icon="hero-bolt" href="#">
                <:trailing>
                  <span class="rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
                    12
                  </span>
                </:trailing>
              </.sidebar_menu_item>
              <.sidebar_menu_item title="Reports" icon="hero-chart-bar-square" href="#" />
            </div>

            <div class="flex flex-col gap-1 group-data-[collapsed=true]/pui-layout:gap-0">
              <p class="px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden">
                Components
              </p>
              <.sidebar_menu_item
                title="Library"
                icon="hero-squares-2x2"
                collapsible
              >
                <:subitem>
                  <.sidebar_subitem href={~p"/docs/button"} current>Button</.sidebar_subitem>
                </:subitem>
                <:subitem>
                  <.sidebar_subitem href={~p"/docs/dialog"}>Dialog</.sidebar_subitem>
                </:subitem>
                <:subitem>
                  <.sidebar_subitem href={~p"/docs/flash"}>Flash</.sidebar_subitem>
                </:subitem>
              </.sidebar_menu_item>
              <.sidebar_menu_item title="Settings" icon="hero-cog-6-tooth" href="#" />
            </div>
          </nav>

          <:footer>
            <div class="border-t border-border p-3 group-data-[collapsed=true]/pui-layout:px-0">
              <.button
                variant="outline"
                size="sm"
                class="w-full justify-start group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:px-0"
              >
                <.icon name="hero-life-buoy" class="size-4" />
                <span class="group-data-[collapsed=true]/pui-layout:hidden">Support</span>
              </.button>
            </div>
          </:footer>
        </.sidebar>
      </:sidebar>

      <:header>
        <.content_header
          shell_id="demo-app-shell"
          title="Demo"
          breadcrumb_parent="PUI Layout"
          breadcrumb_current="Application Shell"
        >
          <:right_actions>
            <.link
              navigate={~p"/docs/layout"}
              class="hidden rounded-lg px-3 py-2 text-sm font-medium text-muted-foreground transition hover:bg-accent hover:text-foreground sm:inline-flex"
            >
              Docs
            </.link>
            <.link
              navigate={~p"/"}
              class="hidden rounded-lg px-3 py-2 text-sm font-medium text-muted-foreground transition hover:bg-accent hover:text-foreground sm:inline-flex"
            >
              Home
            </.link>
            <Layouts.theme_toggle />
          </:right_actions>
        </.content_header>
      </:header>

      <section class="min-h-full p-4 sm:p-6 lg:p-8">
        <div class="mx-auto grid max-w-7xl gap-6 xl:grid-cols-[minmax(0,1.6fr)_minmax(20rem,0.8fr)]">
          <div class="space-y-6">
            <div class="overflow-hidden rounded-md border border-border bg-background shadow-sm">
              <div class="border-b border-border bg-gradient-to-br from-primary/10 via-background to-background p-6 sm:p-8">
                <div class="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
                  <div class="max-w-2xl">
                    <p class="text-sm font-semibold uppercase tracking-[0.22em] text-primary">
                      Full viewport demo
                    </p>
                    <h1 class="mt-3 text-3xl font-semibold tracking-tight text-foreground sm:text-4xl">
                      App layout shell for Phoenix LiveView
                    </h1>
                    <p class="mt-3 text-base leading-7 text-muted-foreground">
                      This page uses PUI layout primitives directly, not an iframe or constrained docs preview.
                      Collapse the sidebar and expand the Library menu to test the bundled hook.
                    </p>
                  </div>
                  <div class="flex flex-wrap gap-2">
                    <.button>New project</.button>
                    <.button variant="outline">Import</.button>
                  </div>
                </div>
              </div>

              <div class="grid gap-4 p-6 md:grid-cols-3">
                <.metric_card label="Open tasks" value="128" trend="+14%" icon="hero-check-circle" />
                <.metric_card label="Deploys" value="42" trend="stable" icon="hero-rocket-launch" />
                <.metric_card label="Incidents" value="3" trend="-2" icon="hero-shield-check" />
              </div>
            </div>

            <.card>
              <.card_header>
                <.card_title>Recent component work</.card_title>
                <.card_description>
                  Example content stays application-owned while PUI owns reusable shell behavior.
                </.card_description>
              </.card_header>
              <.card_content>
                <div class="divide-y divide-border">
                  <.activity_row
                    title="Migrated generated flash UI"
                    status="Done"
                    icon="hero-bell-alert"
                  />
                  <.activity_row
                    title="Moved submenu behavior into PUI hook"
                    status="Review"
                    icon="hero-code-bracket-square"
                  />
                  <.activity_row title="Added full-page layout demo" status="Live" icon="hero-window" />
                </div>
              </.card_content>
            </.card>
          </div>

          <aside class="space-y-6">
            <.card>
              <.card_header>
                <.card_title>Shell traits</.card_title>
                <.card_description>
                  Reusable, configurable, and app-owned where it should be.
                </.card_description>
              </.card_header>
              <.card_content>
                <ul class="space-y-3 text-sm text-muted-foreground">
                  <li class="flex gap-2">
                    <.icon name="hero-check" class="mt-0.5 size-4 text-primary" />
                    Root shell owns `data-collapsed`.
                  </li>
                  <li class="flex gap-2">
                    <.icon name="hero-check" class="mt-0.5 size-4 text-primary" />
                    Sidebar width and content spacing are configurable.
                  </li>
                  <li class="flex gap-2">
                    <.icon name="hero-check" class="mt-0.5 size-4 text-primary" />
                    Collapsible menu state uses `PUI.Sidebar`.
                  </li>
                </ul>
              </.card_content>
            </.card>

            <.card class="bg-primary text-primary-foreground">
              <.card_header>
                <.card_title>Migration target</.card_title>
                <.card_description class="text-primary-foreground/75">
                  Replace generated layout, topbar, flash, and local sidebar code incrementally.
                </.card_description>
              </.card_header>
              <.card_content>
                <.link
                  navigate={~p"/docs/migrate-to-pui"}
                  class="inline-flex rounded-lg bg-primary-foreground px-3 py-2 text-sm font-medium text-primary"
                >
                  Read migration guide
                </.link>
              </.card_content>
            </.card>
          </aside>
        </div>
      </section>
    </.app_layout>
    """
  end

  attr :href, :string, required: true
  attr :current, :boolean, default: false
  slot :inner_block, required: true

  defp sidebar_subitem(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "block rounded-lg px-3 py-1.5 text-sm transition-colors hover:bg-accent hover:text-accent-foreground",
        @current && "bg-primary/10 font-medium text-primary",
        !@current && "text-muted-foreground"
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :trend, :string, required: true
  attr :icon, :string, required: true

  defp metric_card(assigns) do
    ~H"""
    <div class="rounded-md border border-border bg-muted/20 p-5">
      <div class="flex items-center justify-between">
        <p class="text-sm text-muted-foreground">{@label}</p>
        <.icon name={@icon} class="size-5 text-primary" />
      </div>
      <div class="mt-4 flex items-end justify-between gap-3">
        <p class="text-3xl font-semibold tracking-tight text-foreground">{@value}</p>
        <span class="rounded-full bg-background px-2.5 py-1 text-xs font-medium text-muted-foreground">
          {@trend}
        </span>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :status, :string, required: true
  attr :icon, :string, required: true

  defp activity_row(assigns) do
    ~H"""
    <div class="flex items-center gap-4 py-4 first:pt-0 last:pb-0">
      <div class="grid h-10 w-10 shrink-0 place-items-center rounded-md bg-primary/10 text-primary">
        <.icon name={@icon} class="size-5" />
      </div>
      <div class="min-w-0 flex-1">
        <p class="truncate text-sm font-medium text-foreground">{@title}</p>
        <p class="text-xs text-muted-foreground">PUI migration workspace</p>
      </div>
      <span class="rounded-full border border-border px-2.5 py-1 text-xs font-medium text-muted-foreground">
        {@status}
      </span>
    </div>
    """
  end
end
