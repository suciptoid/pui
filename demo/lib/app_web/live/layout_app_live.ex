defmodule AppWeb.Live.LayoutAppLive do
  @moduledoc """
  Full-page demo for the reusable PUI application layout shell.
  """
  use AppWeb, :live_view
  use PUI

  import AppWeb.Live.DemoPages, only: [page_intro: 1, surface: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "App Layout Demo")
     |> assign(:flash_position, "top-right")
     |> assign(:toast_count, 0)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = page_config(Map.get(params, "params_name", "overview"))

    {:noreply,
     socket
     |> assign(:pages, navigation_pages())
     |> assign(:component_pages, component_pages())
     |> assign(:page, page)
     |> assign(:page_title, "#{page.title} - App Layout Demo")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.app_layout id="demo-app-shell" content_class="bg-muted/20 p-0">
      <:sidebar>
        <.sidebar id="demo-app-sidebar" expanded_width_class="w-72">
          <:header>
            <.org_switcher />
          </:header>

          <nav class="flex flex-col gap-3 p-3 group-data-[collapsed=true]/pui-layout:gap-0 group-data-[collapsed=true]/pui-layout:px-0 group-data-[collapsed=true]/pui-layout:py-0">
            <div class="flex flex-col gap-1 group-data-[collapsed=true]/pui-layout:gap-0">
              <p class="px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden">
                Demo pages
              </p>

              <.sidebar_menu_item
                :for={item <- @pages}
                title={item.title}
                icon={item.icon}
                patch={item.path}
                current={item.action == @page.action}
              >
                <:trailing :if={item[:badge]}>
                  <span class="rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary group-data-[collapsed=true]/pui-layout:hidden">
                    {item.badge}
                  </span>
                </:trailing>
              </.sidebar_menu_item>
            </div>

            <div class="flex flex-col gap-1 group-data-[collapsed=true]/pui-layout:gap-0">
              <p class="px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden">
                Components
              </p>

              <.sidebar_menu_item
                :for={item <- @component_pages}
                title={item.title}
                icon={item.icon}
                patch={item.path}
                current={item.action == @page.action}
              />
            </div>

            <div class="flex flex-col gap-1 group-data-[collapsed=true]/pui-layout:gap-0">
              <p class="px-3 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden">
                Documentation
              </p>

              <.sidebar_menu_item
                title="Component Docs"
                icon="hero-squares-2x2"
                collapsible
                expanded
              >
                <:subitem>
                  <.link
                    navigate={~p"/docs/button"}
                    class="block rounded-md px-2 py-1.5 text-sm text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                  >
                    Button
                  </.link>
                </:subitem>
                <:subitem>
                  <.link
                    navigate={~p"/docs/dialog"}
                    class="block rounded-md px-2 py-1.5 text-sm text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                  >
                    Dialog
                  </.link>
                </:subitem>
                <:subitem>
                  <.link
                    navigate={~p"/docs/dropdown"}
                    class="block rounded-md px-2 py-1.5 text-sm text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                  >
                    Dropdown
                  </.link>
                </:subitem>
                <:subitem>
                  <.link
                    navigate={~p"/docs/tabs"}
                    class="block rounded-md px-2 py-1.5 text-sm text-muted-foreground transition hover:bg-accent hover:text-accent-foreground"
                  >
                    Tabs
                  </.link>
                </:subitem>
              </.sidebar_menu_item>
            </div>
          </nav>

          <:footer>
            <.user_menu />
          </:footer>
        </.sidebar>
      </:sidebar>

      <:header>
        <.content_header
          shell_id="demo-app-shell"
          breadcrumb_parent={@page.breadcrumb_parent}
          breadcrumb_current={@page.breadcrumb_current}
        >
          <:right_actions>
            <.button
              navigate={~p"/docs/layout"}
              variant="ghost"
            >
              Layout docs
            </.button>
            <Layouts.theme_toggle />
          </:right_actions>
        </.content_header>
      </:header>

      <PUI.Flash.flash_group :if={@page.action == :flash} flash={%{}} live={true} position={@flash_position} />

      <section class="min-h-full p-4 sm:p-6 lg:p-8">
        <div class="mx-auto flex max-w-7xl flex-col gap-6">
          <%= case @page.action do %>
            <% :overview -> %>
              <.overview_page page={@page} />
            <% :activity -> %>
              <.activity_page page={@page} />
            <% :forms -> %>
              <.forms_page page={@page} />
            <% :components -> %>
              <.components_page page={@page} />
            <% :chart -> %>
              <.chart_page page={@page} />
            <% :settings -> %>
              <.settings_page page={@page} />
            <% :button -> %>
              <AppWeb.Live.DemoPages.button_page page={@page} />
            <% :input -> %>
              <AppWeb.Live.DemoPages.input_page page={@page} />
            <% :select -> %>
              <AppWeb.Live.DemoPages.select_page page={@page} />
            <% :date_picker -> %>
              <AppWeb.Live.DemoPages.date_picker_page page={@page} />
            <% :dialog -> %>
              <AppWeb.Live.DemoPages.dialog_page page={@page} />
            <% :dropdown -> %>
              <AppWeb.Live.DemoPages.dropdown_page page={@page} />
            <% :alert -> %>
              <AppWeb.Live.DemoPages.alert_page page={@page} />
            <% :flash -> %>
              <AppWeb.Live.DemoPages.flash_page page={@page} toast_count={@toast_count} />
            <% :tabs -> %>
              <AppWeb.Live.DemoPages.tabs_page page={@page} />
            <% :accordion -> %>
              <AppWeb.Live.DemoPages.accordion_page page={@page} />
            <% :container -> %>
              <AppWeb.Live.DemoPages.container_page page={@page} />
            <% :charts -> %>
              <AppWeb.Live.DemoPages.charts_page page={@page} />
            <% :popover -> %>
              <AppWeb.Live.DemoPages.popover_page page={@page} />
            <% :loading -> %>
              <AppWeb.Live.DemoPages.loading_page page={@page} />
          <% end %>
        </div>
      </section>
    </.app_layout>
    """
  end

  @impl true
  def handle_event("send_toast", _params, socket) do
    count = socket.assigns.toast_count + 1
    PUI.Flash.send_flash("Toast notification ##{count}!")
    {:noreply, assign(socket, toast_count: count)}
  end

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :trend, :string, required: true
  attr :icon, :string, required: true
  attr :sparkline_id, :string, default: nil
  attr :sparkline, :list, default: []

  defp metric_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-border bg-card p-5">
      <div class="flex items-center justify-between">
        <p class="text-sm font-medium text-muted-foreground">{@label}</p>
        <.icon name={@icon} class="size-4 text-muted-foreground/50" />
      </div>
      <div class="mt-3 flex items-end justify-between gap-2">
        <div>
          <p class="text-2xl font-semibold tracking-tight text-foreground">{@value}</p>
          <span class="mt-0.5 inline-block text-xs font-medium text-muted-foreground">
            {@trend}
          </span>
        </div>
        <div
          :if={@sparkline != [] and @sparkline_id != nil}
          class="w-28 shrink-0 overflow-hidden sm:w-32 xl:w-36"
        >
          <.line_chart
            id={"sparkline-#{@sparkline_id}"}
            sparkline={true}
            height={40}
            series={[%{data: @sparkline}]}
          />
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :meta, :string, required: true
  attr :status, :string, default: nil
  attr :icon, :string, required: true
  slot :detail
  slot :action

  defp activity_row(assigns) do
    ~H"""
    <div class="flex items-start gap-4 py-4 first:pt-0 last:pb-0">
      <div class="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-primary/10 text-primary">
        <.icon name={@icon} class="size-5" />
      </div>
      <div class="min-w-0 flex-1">
        <p class="truncate text-sm font-medium text-foreground">{@title}</p>
        <p class="text-xs text-muted-foreground">{@meta}</p>
        <%= if @detail != [] do %>
          <div class="mt-2 text-sm leading-6 text-muted-foreground">
            {render_slot(@detail)}
          </div>
        <% end %>
      </div>
      <div class="flex items-center gap-2">
        <span
          :if={@status}
          class="rounded-full border border-border px-2.5 py-1 text-xs font-medium text-muted-foreground"
        >
          {@status}
        </span>
        {render_slot(@action)}
      </div>
    </div>
    """
  end

  attr :page, :map, required: true

  defp overview_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.button>
          <.icon name="hero-plus" class="size-4" /> New workspace
        </.button>
      </:action>
      <:action>
        <.menu_button variant="outline">
          Quick actions
          <:item>Share update</:item>
          <:item>Export brief</:item>
          <:item>Sync docs</:item>
        </.menu_button>
      </:action>
    </.page_intro>

    <.surface
      title="A realistic dashboard surface"
      description="The content area now spans the full shell width and shows buttons, alerts, list items, tabs, and menus in ordinary application patterns."
    >
      <div class="grid gap-4 md:grid-cols-3">
        <.metric_card
          label="Open tasks"
          value="128"
          trend="+14% this week"
          icon="hero-check-circle"
          sparkline_id="tasks"
          sparkline={[85, 92, 88, 101, 109, 115, 128]}
        />
        <.metric_card
          label="Deploys"
          value="42"
          trend="Stable"
          icon="hero-rocket-launch"
          sparkline_id="deploys"
          sparkline={[38, 40, 39, 41, 40, 42, 42]}
        />
        <.metric_card
          label="Incidents"
          value="3"
          trend="−2 vs last week"
          icon="hero-shield-check"
          sparkline_id="incidents"
          sparkline={[9, 7, 8, 6, 7, 5, 3]}
        />
      </div>

      <div class="mt-6 grid gap-6 xl:grid-cols-[minmax(0,1.2fr)_minmax(0,0.8fr)]">
        <div class="space-y-6">
          <.surface
            title="Delivery trend"
            description="A lightweight line chart makes the dashboard feel like a real workspace instead of a stack of disconnected cards."
          >
            <.line_chart
              id="layout-overview-chart"
              card={false}
              area={true}
              height={240}
              labels={overview_chart_labels()}
              series={overview_chart_series()}
            />
          </.surface>

          <.alert>
            <:icon>
              <.icon name="hero-sparkles" class="size-4" />
            </:icon>
            <:title>Shell behavior stays reusable, page content stays app-owned.</:title>
            <:description>
              The sidebar, header toggle, menus, and breadcrumb are shared primitives while each route showcases its own component composition.
            </:description>
          </.alert>

          <div class="divide-y divide-border">
            <.activity_row
              title="Launch checklist"
              meta="Form fields, radios, select, and switches grouped in one flow"
              status="Ready"
              icon="hero-clipboard-document-check"
            >
              <:detail>
                Use PUI inputs for basic data capture, then pair them with alerts and buttons for guided submission flows.
              </:detail>
              <:action>
                <.menu_button variant="ghost" class="h-8 w-8 px-0">
                  <.icon name="hero-ellipsis-horizontal" class="size-4" />
                  <:item>Open form</:item>
                  <:item>Duplicate flow</:item>
                </.menu_button>
              </:action>
            </.activity_row>

            <.activity_row
              title="Component review queue"
              meta="Dropdown actions attached to list items without extra layout wrappers"
              status="12 open"
              icon="hero-rectangle-stack"
            >
              <:detail>
                Menu buttons, hover states, and status chips sit directly inside each list row so the examples feel like actual product UI.
              </:detail>
              <:action>
                <.menu_button variant="ghost" class="h-8 w-8 px-0">
                  <.icon name="hero-ellipsis-horizontal" class="size-4" />
                  <:item>Assign reviewer</:item>
                  <:item>Archive row</:item>
                </.menu_button>
              </:action>
            </.activity_row>

            <.activity_row
              title="Release prep"
              meta="Tabs for context switching and alerts for stateful status messaging"
              status="Live"
              icon="hero-window"
            >
              <:detail>
                The same primitives work in summary cards, content panels, and sticky headers without changing the shell theme.
              </:detail>
            </.activity_row>
          </div>
        </div>

        <div class="rounded-lg border border-border bg-muted/20 p-4">
          <.tabs id="overview-pattern-tabs" default_value="handoff">
            <:trigger value="handoff">Handoff</:trigger>
            <:trigger value="list-item">List item</:trigger>
            <:trigger value="feedback">Feedback</:trigger>
            <:content value="handoff" class="pt-4">
              <div class="space-y-4">
                <p class="text-sm leading-6 text-muted-foreground">
                  Use tabs when one workspace needs multiple dense panels without sending the user to another route.
                </p>
                <div class="rounded-lg border border-border bg-background p-4">
                  <p class="text-sm font-medium text-foreground">Primary handoff</p>
                  <p class="mt-1 text-sm text-muted-foreground">
                    Pair one primary button with a quieter outline action to keep hierarchy clear.
                  </p>
                  <div class="mt-4 flex flex-wrap gap-2">
                    <.button size="sm">Approve layout</.button>
                    <.button variant="outline" size="sm">Leave note</.button>
                  </div>
                </div>
              </div>
            </:content>
            <:content value="list-item" class="pt-4">
              <div class="rounded-lg border border-border bg-background p-4">
                <.activity_row
                  title="Sidebar navigation"
                  meta="Patch-based route changes keep the LiveView mounted"
                  status="Patched"
                  icon="hero-bars-3-bottom-left"
                >
                  <:detail>
                    Each sidebar item now points to its own `live_action`, updates the breadcrumb, and swaps in a new content composition.
                  </:detail>
                </.activity_row>
              </div>
            </:content>
            <:content value="feedback" class="pt-4">
              <.alert>
                <:icon>
                  <.icon name="hero-information-circle" class="size-4" />
                </:icon>
                <:title>Feedback surfaces should stay close to the work.</:title>
                <:description>
                  Use inline alerts for context, not detached sidebars that compete with the page content.
                </:description>
              </.alert>
            </:content>
          </.tabs>
        </div>
      </div>
    </.surface>
    """
  end

  attr :page, :map, required: true

  defp chart_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.button variant="outline">
          <.icon name="hero-arrow-down-tray" class="size-4" /> Export snapshot
        </.button>
      </:action>
      <:action>
        <.menu_button variant="outline">
          Chart actions
          <:item>Share report</:item>
          <:item>Duplicate dashboard</:item>
          <:item>Pin to overview</:item>
        </.menu_button>
      </:action>
    </.page_intro>

    <div class="grid gap-6 xl:grid-cols-[minmax(0,1.2fr)_minmax(0,0.8fr)]">
      <.surface
        title="Throughput by release"
        description="The dedicated chart page lets the shell host larger analytical views without changing the sidebar, header, or page rhythm."
      >
        <.line_chart
          id="layout-chart-primary"
          card={false}
          height={300}
          labels={chart_page_line_labels()}
          series={chart_page_line_series()}
        />
      </.surface>

      <.surface
        title="Shipments by channel"
        description="This chart uses the preconfigured bar_chart helper with the same shell spacing and card rhythm."
      >
        <.bar_chart
          id="layout-chart-secondary"
          card={false}
          height={300}
          categories={chart_page_bar_categories()}
          series={chart_page_bar_series()}
          tooltip={%{}}
        />
      </.surface>
    </div>

    <.surface
      title="How to use this route"
      description="This page is intentionally simple: a dedicated menu destination for chart-heavy content inside the same reusable shell."
    >
      <div class="grid gap-4 md:grid-cols-3">
        <.metric_card label="Tracked releases" value="18" trend="+3" icon="hero-rocket-launch" />
        <.metric_card label="Active channels" value="6" trend="Stable" icon="hero-signal" />
        <.metric_card label="Alerting rules" value="24" trend="+5%" icon="hero-bell-alert" />
      </div>
    </.surface>
    """
  end

  attr :page, :map, required: true

  defp activity_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.menu_button variant="outline">
          Filter stream
          <:item>Everything</:item>
          <:item>Comments</:item>
          <:item>Approvals</:item>
        </.menu_button>
      </:action>
      <:action>
        <.button variant="secondary">
          <.icon name="hero-arrow-path" class="size-4" /> Refresh
        </.button>
      </:action>
    </.page_intro>

    <.surface
      title="Event feed"
      description="This page leans on list items, dropdown menus, tooltip triggers, and alerts to show how PUI behaves inside busy operational content."
    >
      <.alert>
        <:icon>
          <.icon name="hero-bolt" class="size-4" />
        </:icon>
        <:title>12 new events need attention.</:title>
        <:description>
          Activity views are a good place to mix dense metadata, hover help, and per-row actions without introducing a second sidebar.
        </:description>
      </.alert>

      <div class="mt-6 divide-y divide-border">
        <.activity_row
          title="Comment added to launch brief"
          meta="3 minutes ago - Product design"
          status="Unread"
          icon="hero-chat-bubble-left-right"
        >
          <:detail>
            "Let's keep the neutral palette and move the quick actions into the full-width content lane."
          </:detail>
          <:action>
            <.tooltip id="activity-row-tooltip-1" placement="top">
              <.button variant="ghost" size="icon">
                <.icon name="hero-eye" class="size-4" />
              </.button>
              <:tooltip>Preview comment thread</:tooltip>
            </.tooltip>
          </:action>
          <:action>
            <.menu_button variant="ghost" class="h-8 w-8 px-0">
              <.icon name="hero-ellipsis-horizontal" class="size-4" />
              <:item>Open thread</:item>
              <:item>Assign owner</:item>
              <:item>Mute row</:item>
            </.menu_button>
          </:action>
        </.activity_row>

        <.activity_row
          title="Prototype approved"
          meta="26 minutes ago - Growth squad"
          status="Done"
          icon="hero-check-badge"
        >
          <:detail>
            Approvals read cleanly with a small status chip and a quiet ghost action for drill-down.
          </:detail>
          <:action>
            <.tooltip id="activity-row-tooltip-2" placement="top">
              <.button variant="ghost" size="icon">
                <.icon name="hero-document-text" class="size-4" />
              </.button>
              <:tooltip>Open decision log</:tooltip>
            </.tooltip>
          </:action>
        </.activity_row>

        <.activity_row
          title="Release notes updated"
          meta="1 hour ago - Engineering"
          status="Review"
          icon="hero-pencil-square"
        >
          <:detail>
            Buttons, menu items, and tooltip triggers can all sit on the same row when spacing stays tight and consistent.
          </:detail>
          <:action>
            <.menu_button variant="ghost" class="h-8 w-8 px-0">
              <.icon name="hero-ellipsis-horizontal" class="size-4" />
              <:item>Edit note</:item>
              <:item>Pin update</:item>
            </.menu_button>
          </:action>
        </.activity_row>
      </div>
    </.surface>

    <.surface
      title="Drill into one thread"
      description="Accordions and popovers are useful when activity pages need more depth without leaving the route."
    >
      <div class="grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)]">
        <.accordion class="rounded-lg border border-border px-4">
          <.accordion_item name="activity-review" open>
            <.accordion_trigger>What changed in this iteration?</.accordion_trigger>
            <.accordion_content>
              <p class="pb-4 text-sm leading-6 text-muted-foreground">
                The right-side column is gone, content spans the remaining width, and navigation now patches between route-backed demo pages.
              </p>
            </.accordion_content>
          </.accordion_item>
          <.accordion_item name="activity-review">
            <.accordion_trigger>Which components are represented here?</.accordion_trigger>
            <.accordion_content>
              <p class="pb-4 text-sm leading-6 text-muted-foreground">
                Alerts, list rows, dropdown menus, tooltips, accordions, buttons, and the shared shell header all appear in one flow.
              </p>
            </.accordion_content>
          </.accordion_item>
          <.accordion_item name="activity-review">
            <.accordion_trigger>Why keep the design restrained?</.accordion_trigger>
            <.accordion_content>
              <p class="pb-4 text-sm leading-6 text-muted-foreground">
                The goal is a believable product shell that stays aligned with the existing monochrome PUI aesthetic and corner radius scale.
              </p>
            </.accordion_content>
          </.accordion_item>
        </.accordion>

        <div class="rounded-lg border border-border bg-muted/20 p-5">
          <p class="text-sm font-medium text-foreground">Popover usage</p>
          <p class="mt-1 text-sm leading-6 text-muted-foreground">
            Use a popover for compact context, especially when you do not want a full dialog to interrupt the stream.
          </p>

          <div class="mt-5">
            <.popover_base
              id="activity-page-popover"
              class="w-fit"
              phx-hook="PUI.Popover"
              data-placement="bottom-start"
            >
              <:trigger class="inline-flex h-9 items-center justify-center gap-2 rounded-lg border border-border bg-background px-4 text-sm font-medium text-foreground shadow-xs transition hover:bg-accent">
                <.icon name="hero-funnel" class="size-4" /> Inspect filter summary
              </:trigger>
              <:popup class="aria-hidden:hidden block z-50 w-72 rounded-lg border border-border bg-popover p-4 text-popover-foreground shadow-lg">
                <div class="space-y-3">
                  <p class="text-sm font-medium">Active filters</p>
                  <ul class="space-y-2 text-sm text-muted-foreground">
                    <li class="flex items-center justify-between">
                      <span>Owners</span>
                      <span class="font-medium text-foreground">Design + Eng</span>
                    </li>
                    <li class="flex items-center justify-between">
                      <span>State</span>
                      <span class="font-medium text-foreground">Unread</span>
                    </li>
                    <li class="flex items-center justify-between">
                      <span>Range</span>
                      <span class="font-medium text-foreground">Last 24h</span>
                    </li>
                  </ul>
                </div>
              </:popup>
            </.popover_base>
          </div>
        </div>
      </div>
    </.surface>
    """
  end

  attr :page, :map, required: true

  defp forms_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.button>
          <.icon name="hero-paper-airplane" class="size-4" /> Submit request
        </.button>
      </:action>
      <:action>
        <.button variant="outline">Save draft</.button>
      </:action>
    </.page_intro>

    <.surface
      title="Forms with richer surrounding UI"
      description="The examples below mix inputs, textarea, select, radio, checkbox, switch, alerts, and action buttons inside one believable request flow."
    >
      <div class="grid gap-8 lg:grid-cols-[minmax(0,1.15fr)_minmax(0,0.85fr)]">
        <form class="space-y-1">
          <div class="grid gap-4 md:grid-cols-2">
            <.input id="layout-project-name" label="Project name" placeholder="Command center" />
            <.input id="layout-owner" label="Owner" placeholder="Maya Chen" />
          </div>

          <div class="grid gap-4 md:grid-cols-2">
            <.input
              id="layout-owner-email"
              type="email"
              label="Owner email"
              placeholder="maya@acme.test"
            />
            <.select
              id="layout-project-stage"
              label="Stage"
              options={["Discovery", "Build", "Launch"]}
            />
          </div>

          <.textarea
            id="layout-brief"
            label="Brief"
            rows="5"
            placeholder="Describe what the team needs from this workspace."
          />

          <div class="grid gap-6 md:grid-cols-2">
            <div class="space-y-3 rounded-lg border border-border p-4">
              <p class="text-sm font-medium text-foreground">Timeline</p>
              <label class="flex items-center gap-3 text-sm text-muted-foreground">
                <.radio id="timeline-now" name="timeline" value="now" /> Launch this week
              </label>
              <label class="flex items-center gap-3 text-sm text-muted-foreground">
                <.radio id="timeline-next" name="timeline" value="next" /> Ship next sprint
              </label>
              <label class="flex items-center gap-3 text-sm text-muted-foreground">
                <.radio id="timeline-later" name="timeline" value="later" /> Track for later
              </label>
            </div>

            <div class="space-y-3 rounded-lg border border-border p-4">
              <p class="text-sm font-medium text-foreground">Delivery preferences</p>
              <.checkbox id="weekly-digest" name="weekly_digest" label="Send weekly digest" />
              <.checkbox id="share-preview" name="share_preview" label="Share preview link" />
              <.switch id="require-review" name="require_review" label="Require design review" />
            </div>
          </div>

          <div class="pt-3">
            <.select
              id="layout-squad"
              label="Squad"
              searchable={true}
              options={[
                {"Design", ["Product design", "Brand design"]},
                {"Engineering", ["Platform", "Frontend"]}
              ]}
            />
          </div>

          <div class="flex flex-wrap gap-2 pt-2">
            <.button>Submit request</.button>
            <.button variant="outline">Preview summary</.button>
          </div>
        </form>

        <div class="space-y-6">
          <.alert>
            <:icon>
              <.icon name="hero-information-circle" class="size-4" />
            </:icon>
            <:title>Forms benefit from nearby feedback.</:title>
            <:description>
              Keep guidance, previews, and next actions in the same lane as the inputs instead of pushing them into a detached sidebar.
            </:description>
          </.alert>

          <div class="rounded-lg border border-border bg-muted/20 p-5">
            <p class="text-sm font-medium text-foreground">Request preview</p>
            <div class="mt-4 space-y-4">
              <div class="rounded-lg border border-border bg-background p-4">
                <p class="text-sm font-medium text-foreground">Command center</p>
                <p class="mt-1 text-sm text-muted-foreground">
                  Workspace shell for launch planning, approvals, and live component examples.
                </p>
              </div>

              <div class="divide-y divide-border rounded-lg border border-border bg-background px-4">
                <.activity_row
                  title="Assigned squad"
                  meta="Select component with grouped options"
                  status="Pending"
                  icon="hero-user-group"
                />
                <.activity_row
                  title="Review workflow"
                  meta="Checkboxes and switches keep binary choices compact"
                  status="Needs owner"
                  icon="hero-adjustments-horizontal"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </.surface>

    <.surface
      title="Form inside a dialog"
      description="Collect structured input through a modal overlay. The dialog keeps focus trapped and preserves form state while open."
    >
      <div class="flex items-center gap-4">
        <.dialog id="form-dialog" title="Create new project" size="lg">
          <:trigger :let={attr}>
            <.button {attr}>
              <.icon name="hero-plus" class="size-4" /> New project
            </.button>
          </:trigger>
          <form class="space-y-1">
            <.input
              id="dialog-project-name"
              label="Project name"
              placeholder="My new project"
            />
            <.textarea
              id="dialog-project-description"
              label="Description"
              rows="4"
              placeholder="What is this project about?"
            />
            <.select
              id="dialog-project-category"
              label="Category"
              options={["Engineering", "Design", "Marketing", "Operations"]}
            />
          </form>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end gap-2">
              <.button variant="outline" phx-click={hide}>Cancel</.button>
              <.button>Create project</.button>
            </div>
          </:footer>
        </.dialog>

        <p class="text-sm text-muted-foreground">
          Click the button above to open a dialog containing a text input, textarea, and select.
        </p>
      </div>
    </.surface>
    """
  end

  attr :page, :map, required: true

  defp components_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.menu_button variant="outline">
          Export examples
          <:item>Copy snippet</:item>
          <:item>Open docs</:item>
        </.menu_button>
      </:action>
      <:action>
        <.button variant="secondary">Pin canvas</.button>
      </:action>
    </.page_intro>

    <.surface
      title="Interactive component canvas"
      description="This route groups tabs, dropdowns, popovers, dialogs, buttons, and alerts into the kind of exploratory workspace you would ship in a demo app."
    >
      <div class="grid gap-6 xl:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)]">
        <div class="rounded-lg border border-border bg-muted/20 p-4">
          <.tabs id="component-canvas-tabs" default_value="navigation">
            <:trigger value="navigation">Navigation</:trigger>
            <:trigger value="feedback">Feedback</:trigger>
            <:trigger value="patterns">Patterns</:trigger>
            <:content value="navigation" class="pt-4">
              <div class="space-y-4">
                <p class="text-sm leading-6 text-muted-foreground">
                  A sidebar page can still use in-content navigation patterns like tabs when the content is dense and related.
                </p>
                <div class="flex flex-wrap gap-2">
                  <.button size="sm">Primary action</.button>
                  <.button variant="outline" size="sm">Secondary action</.button>
                  <.menu_button variant="ghost" class="h-8 px-3">
                    More
                    <:item>Duplicate</:item>
                    <:item>Archive</:item>
                  </.menu_button>
                </div>
              </div>
            </:content>
            <:content value="feedback" class="pt-4">
              <div class="space-y-4">
                <.alert>
                  <:icon>
                    <.icon name="hero-check-circle" class="size-4" />
                  </:icon>
                  <:title>Success feedback stays close to the panel.</:title>
                  <:description>
                    Alerts work well inside tabs when users need confirmation without leaving context.
                  </:description>
                </.alert>
                <div class="rounded-lg border border-border bg-background p-4 text-sm text-muted-foreground">
                  You can mix static guidance and interactive actions inside the same tab panel without losing the shell hierarchy.
                </div>
              </div>
            </:content>
            <:content value="patterns" class="pt-4">
              <div class="space-y-4">
                <p class="text-sm leading-6 text-muted-foreground">
                  Real demos should show components behaving inside patterns like task rows, approvals, and settings blocks, not only in isolated docs frames.
                </p>
                <.accordion>
                  <.accordion_item name="component-patterns" open>
                    <.accordion_trigger>Pattern 1 - Dense list rows</.accordion_trigger>
                    <.accordion_content>
                      <p class="pb-4 text-sm text-muted-foreground">
                        Pair a list row with status chips and ghost menus for operational pages.
                      </p>
                    </.accordion_content>
                  </.accordion_item>
                  <.accordion_item name="component-patterns">
                    <.accordion_trigger>Pattern 2 - Context popovers</.accordion_trigger>
                    <.accordion_content>
                      <p class="pb-4 text-sm text-muted-foreground">
                        Use popovers for filter summaries and quick read-only context.
                      </p>
                    </.accordion_content>
                  </.accordion_item>
                </.accordion>
              </div>
            </:content>
          </.tabs>
        </div>

        <div class="space-y-6">
          <div class="rounded-lg border border-border bg-muted/20 p-5">
            <p class="text-sm font-medium text-foreground">Popover example</p>
            <div class="mt-4">
              <.popover_base
                id="components-page-popover"
                class="w-fit"
                phx-hook="PUI.Popover"
                data-placement="bottom-start"
              >
                <:trigger class="inline-flex h-9 items-center justify-center gap-2 rounded-lg border border-border bg-background px-4 text-sm font-medium text-foreground shadow-xs transition hover:bg-accent">
                  <.icon name="hero-eye-dropper" class="size-4" /> Inspect spacing notes
                </:trigger>
                <:popup class="aria-hidden:hidden block z-50 w-72 rounded-lg border border-border bg-popover p-4 text-popover-foreground shadow-lg">
                  <div class="space-y-2">
                    <p class="text-sm font-medium">Spacing guidance</p>
                    <p class="text-sm leading-6 text-muted-foreground">
                      Use one content column, stronger section rhythm, and component groupings that feel like product UI rather than isolated docs blocks.
                    </p>
                  </div>
                </:popup>
              </.popover_base>
            </div>
          </div>

          <div class="rounded-lg border border-border bg-muted/20 p-5">
            <p class="text-sm font-medium text-foreground">Dialog example</p>
            <p class="mt-1 text-sm leading-6 text-muted-foreground">
              Dialogs are still useful for previewing a compact flow when the content needs focus.
            </p>

            <div class="mt-4">
              <.dialog id="components-preview-dialog" title="Component preview">
                <:trigger :let={attrs}>
                  <.button variant="outline" {attrs}>Open preview dialog</.button>
                </:trigger>

                <div class="space-y-4 text-sm text-muted-foreground">
                  <p>
                    This preview keeps the existing PUI design language while demonstrating a tighter, route-driven layout shell.
                  </p>
                  <div class="rounded-lg border border-border bg-muted/20 p-4">
                    <p class="font-medium text-foreground">Shown inside the dialog</p>
                    <p class="mt-1">
                      Buttons, body copy, and footer actions stay on the same radius and border scale as the rest of the demo.
                    </p>
                  </div>
                </div>

                <:footer :let={%{hide: hide}}>
                  <div class="flex justify-end gap-2">
                    <.button variant="outline" phx-click={hide}>Close</.button>
                    <.button>Apply pattern</.button>
                  </div>
                </:footer>
              </.dialog>
            </div>
          </div>
        </div>
      </div>
    </.surface>
    """
  end

  attr :page, :map, required: true

  defp settings_page(assigns) do
    ~H"""
    <.page_intro page={@page}>
      <:action>
        <.button>Save changes</.button>
      </:action>
      <:action>
        <.button variant="outline">Reset</.button>
      </:action>
    </.page_intro>

    <.surface
      title="Workspace preferences"
      description="Settings pages are a natural place to combine form controls, tabs, alerts, and dialog actions while keeping the shell calm and structured."
    >
      <div class="grid gap-8 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
        <div class="space-y-6">
          <div class="grid gap-4 md:grid-cols-2">
            <.input id="settings-workspace-name" label="Workspace name" placeholder="PUI Console" />
            <.select
              id="settings-timezone"
              label="Timezone"
              options={["UTC", "WIB", "PST", "CET"]}
            />
          </div>

          <div class="rounded-lg border border-border p-5">
            <p class="text-sm font-medium text-foreground">Notifications</p>
            <div class="mt-4 space-y-4">
              <.switch id="settings-digest" name="digest" label="Weekly summary email" />
              <.switch id="settings-mentions" name="mentions" label="Mention alerts" />
              <.checkbox id="settings-ops" name="ops" label="Escalate critical incidents" />
            </div>
          </div>

          <div class="rounded-lg border border-border p-5">
            <p class="text-sm font-medium text-foreground">Approval defaults</p>
            <div class="mt-4 grid gap-4 md:grid-cols-2">
              <label class="flex items-center gap-3 text-sm text-muted-foreground">
                <.radio id="approval-strict" name="approval-mode" value="strict" />
                Require two reviewers
              </label>
              <label class="flex items-center gap-3 text-sm text-muted-foreground">
                <.radio id="approval-light" name="approval-mode" value="light" /> Allow one reviewer
              </label>
            </div>
          </div>
        </div>

        <div class="space-y-6">
          <.tabs id="settings-tabs" default_value="guidance" variant="line">
            <:trigger value="guidance">Guidance</:trigger>
            <:trigger value="ownership">Ownership</:trigger>
            <:content value="guidance" class="pt-4">
              <.alert>
                <:icon>
                  <.icon name="hero-information-circle" class="size-4" />
                </:icon>
                <:title>Use line tabs for compact supporting content.</:title>
                <:description>
                  They work well in settings side panels where users need supporting guidance without leaving the form.
                </:description>
              </.alert>
            </:content>
            <:content value="ownership" class="pt-4">
              <div class="rounded-lg border border-border bg-muted/20 p-4 text-sm text-muted-foreground">
                Keep workspace ownership nearby so settings, alerts, and destructive actions all feel part of the same decision surface.
              </div>
            </:content>
          </.tabs>

          <div class="rounded-lg border border-border bg-muted/20 p-5">
            <p class="text-sm font-medium text-foreground">Danger zone</p>
            <p class="mt-1 text-sm leading-6 text-muted-foreground">
              Destructive actions should be obvious, isolated, and confirmed with a dialog.
            </p>

            <div class="mt-4 space-y-4">
              <.alert variant="destructive">
                <:icon>
                  <.icon name="hero-exclamation-triangle" class="size-4" />
                </:icon>
                <:title>Deleting this workspace removes its saved views.</:title>
                <:description>
                  Use a destructive alert to set context before the confirmation dialog opens.
                </:description>
              </.alert>

              <.dialog id="settings-delete-dialog" title="Delete workspace" alert={true}>
                <:trigger :let={attrs}>
                  <.button variant="destructive" {attrs}>Delete workspace</.button>
                </:trigger>

                <p class="text-sm leading-6 text-muted-foreground">
                  This demo action shows how a destructive flow can stay aligned with the same border, spacing, and radius system as the rest of the shell.
                </p>

                <:footer :let={%{hide: hide}}>
                  <div class="flex justify-end gap-2">
                    <.button variant="outline" phx-click={hide}>Cancel</.button>
                    <.button variant="destructive">Delete</.button>
                  </div>
                </:footer>
              </.dialog>
            </div>
          </div>
        </div>
      </div>
    </.surface>
    """
  end

  defp navigation_pages do
    Enum.map(
      [:overview, :activity, :forms, :components, :chart, :settings],
      &page_config/1
    )
  end

  defp component_pages do
    Enum.map(
      [:button, :input, :select, :date_picker, :dialog, :dropdown, :alert, :flash, :tabs, :accordion, :container, :charts, :popover, :loading],
      &page_config/1
    )
  end

  defp page_config(action) do
    action = normalize_page_action(action)
    path = page_path(action)

    case action do
      :overview ->
        %{
          action: :overview,
          title: "Overview",
          eyebrow: "Layout overview",
          description:
            "A full-width dashboard page that demonstrates how the PUI shell can host lists, tabs, alerts, menus, and action groups without leaning on a secondary sidebar.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Overview",
          icon: "hero-home",
          path: path
        }

      :activity ->
        %{
          action: :activity,
          title: "Activity",
          eyebrow: "Operational feed",
          description:
            "A route dedicated to list items, tooltip triggers, dropdown actions, accordions, and popovers so activity-heavy interfaces feel like a real product surface.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Activity",
          icon: "hero-bolt",
          path: path,
          badge: "12"
        }

      :forms ->
        %{
          action: :forms,
          title: "Forms",
          eyebrow: "Input patterns",
          description:
            "Form fields, selects, radios, toggles, alerts, and preview cards grouped together to show how PUI components behave in submission flows.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Forms",
          icon: "hero-pencil-square",
          path: path
        }

      :components ->
        %{
          action: :components,
          title: "Components",
          eyebrow: "Interactive canvas",
          description:
            "Tabs, popovers, dialogs, alerts, dropdowns, and accordions arranged as a compact component lab instead of isolated documentation snippets.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Components",
          icon: "hero-squares-2x2",
          path: path
        }

      :chart ->
        %{
          action: :chart,
          title: "Chart",
          eyebrow: "Chart surfaces",
          description:
            "A dedicated layout route for dummy dashboard charts, larger analytical panels, and chart-first content inside the same application shell.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Chart",
          icon: "hero-chart-bar",
          path: path
        }

      :settings ->
        %{
          action: :settings,
          title: "Settings",
          eyebrow: "Preference surfaces",
          description:
            "A settings page that combines form controls, guidance tabs, and destructive confirmation patterns while staying inside the same shell language.",
          breadcrumb_parent: "Layout showcase",
          breadcrumb_current: "Settings",
          icon: "hero-cog-6-tooth",
          path: path
        }

      :button ->
        %{action: :button, title: "Button", eyebrow: "Button component", description: "All button variants, sizes, states, and icon combinations.", breadcrumb_parent: "Components", breadcrumb_current: "Button", icon: "hero-cursor-arrow-rays", path: path}

      :input ->
        %{action: :input, title: "Input", eyebrow: "Input component", description: "Text inputs, textarea, checkbox, radio, switch, and error states.", breadcrumb_parent: "Components", breadcrumb_current: "Input", icon: "hero-pencil-square", path: path}

      :select ->
        %{action: :select, title: "Select", eyebrow: "Select component", description: "Basic, searchable, grouped, and custom select variants.", breadcrumb_parent: "Components", breadcrumb_current: "Select", icon: "hero-chevron-down", path: path}

      :date_picker ->
        %{action: :date_picker, title: "Date Picker", eyebrow: "Date picker component", description: "Single date, range, bounded, and footer slot variants.", breadcrumb_parent: "Components", breadcrumb_current: "Date Picker", icon: "hero-calendar-days", path: path}

      :dialog ->
        %{action: :dialog, title: "Dialog", eyebrow: "Dialog component", description: "Sizes, alert mode, scrollable, and form-in-dialog patterns.", breadcrumb_parent: "Components", breadcrumb_current: "Dialog", icon: "hero-window", path: path}

      :dropdown ->
        %{action: :dropdown, title: "Dropdown", eyebrow: "Dropdown component", description: "Basic menus, shortcuts, destructive items, and button variants.", breadcrumb_parent: "Components", breadcrumb_current: "Dropdown", icon: "hero-chevron-up-down", path: path}

      :alert ->
        %{action: :alert, title: "Alert", eyebrow: "Alert component", description: "Default, destructive, and custom content alert variants.", breadcrumb_parent: "Components", breadcrumb_current: "Alert", icon: "hero-exclamation-triangle", path: path}

      :flash ->
        %{action: :flash, title: "Flash", eyebrow: "Flash component", description: "Live toast notifications with configurable positions.", breadcrumb_parent: "Components", breadcrumb_current: "Flash", icon: "hero-bolt", path: path}

      :tabs ->
        %{action: :tabs, title: "Tabs", eyebrow: "Tabs component", description: "Client-controlled, line variant, and vertical tab layouts.", breadcrumb_parent: "Components", breadcrumb_current: "Tabs", icon: "hero-squares-2x2", path: path}

      :accordion ->
        %{action: :accordion, title: "Accordion", eyebrow: "Accordion component", description: "Single-open, multiple-open, and headless accordion variants.", breadcrumb_parent: "Components", breadcrumb_current: "Accordion", icon: "hero-bars-3", path: path}

      :container ->
        %{action: :container, title: "Container", eyebrow: "Container component", description: "Card with header, content, action, and footer slots.", breadcrumb_parent: "Components", breadcrumb_current: "Container", icon: "hero-square-3-stack-3d", path: path}

      :charts ->
        %{action: :charts, title: "Charts", eyebrow: "Chart component", description: "Bar, line, area, sparkline, and colocated hook chart demos.", breadcrumb_parent: "Components", breadcrumb_current: "Charts", icon: "hero-chart-bar", path: path}

      :popover ->
        %{action: :popover, title: "Popover", eyebrow: "Popover & Tooltip", description: "Click-triggered popovers and hover tooltips in all placements.", breadcrumb_parent: "Components", breadcrumb_current: "Popover", icon: "hero-chat-bubble-bottom-center-text", path: path}

      :loading ->
        %{action: :loading, title: "Loading", eyebrow: "Loading component", description: "Loading topbar that activates during page navigation.", breadcrumb_parent: "Components", breadcrumb_current: "Loading", icon: "hero-arrow-path", path: path}

      _ ->
        page_config(:overview)
    end
  end

  defp normalize_page_action("overview"), do: :overview
  defp normalize_page_action("activity"), do: :activity
  defp normalize_page_action("forms"), do: :forms
  defp normalize_page_action("components"), do: :components
  defp normalize_page_action("chart"), do: :chart
  defp normalize_page_action("settings"), do: :settings
  defp normalize_page_action("button"), do: :button
  defp normalize_page_action("input"), do: :input
  defp normalize_page_action("select"), do: :select
  defp normalize_page_action("date-picker"), do: :date_picker
  defp normalize_page_action("dialog"), do: :dialog
  defp normalize_page_action("dropdown"), do: :dropdown
  defp normalize_page_action("alert"), do: :alert
  defp normalize_page_action("flash"), do: :flash
  defp normalize_page_action("tabs"), do: :tabs
  defp normalize_page_action("accordion"), do: :accordion
  defp normalize_page_action("container"), do: :container
  defp normalize_page_action("charts"), do: :charts
  defp normalize_page_action("popover"), do: :popover
  defp normalize_page_action("loading"), do: :loading

  defp normalize_page_action(action)
       when action in [
              :overview,
              :activity,
              :forms,
              :components,
              :chart,
              :settings,
              :button,
              :input,
              :select,
              :date_picker,
              :dialog,
              :dropdown,
              :alert,
              :flash,
              :tabs,
              :accordion,
              :container,
              :charts,
              :popover,
              :loading
            ],
       do: action

  defp normalize_page_action(_), do: :overview

  defp page_path(:overview), do: ~p"/demo/overview"
  defp page_path(:activity), do: ~p"/demo/activity"
  defp page_path(:forms), do: ~p"/demo/forms"
  defp page_path(:components), do: ~p"/demo/components"
  defp page_path(:chart), do: ~p"/demo/chart"
  defp page_path(:settings), do: ~p"/demo/settings"
  defp page_path(:button), do: ~p"/demo/button"
  defp page_path(:input), do: ~p"/demo/input"
  defp page_path(:select), do: ~p"/demo/select"
  defp page_path(:date_picker), do: ~p"/demo/date-picker"
  defp page_path(:dialog), do: ~p"/demo/dialog"
  defp page_path(:dropdown), do: ~p"/demo/dropdown"
  defp page_path(:alert), do: ~p"/demo/alert"
  defp page_path(:flash), do: ~p"/demo/flash"
  defp page_path(:tabs), do: ~p"/demo/tabs"
  defp page_path(:accordion), do: ~p"/demo/accordion"
  defp page_path(:container), do: ~p"/demo/container"
  defp page_path(:charts), do: ~p"/demo/charts"
  defp page_path(:popover), do: ~p"/demo/popover"
  defp page_path(:loading), do: ~p"/demo/loading"

  defp overview_chart_labels do
    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  end

  defp overview_chart_series do
    [
      %{label: "Completed", data: [28, 34, 31, 39, 42, 37, 45], suffix: " tasks"},
      %{label: "Queued", data: [18, 21, 19, 24, 26, 22, 25], suffix: " tasks"}
    ]
  end

  defp chart_page_line_labels do
    ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"]
  end

  defp chart_page_line_series do
    [
      %{label: "Web", data: [62, 66, 70, 74, 78, 81], suffix: " req/s"},
      %{label: "API", data: [48, 51, 55, 57, 60, 64], suffix: " req/s"},
      %{label: "Worker", data: [29, 32, 34, 38, 41, 43], suffix: " req/s"}
    ]
  end

  defp chart_page_bar_categories do
    ["Direct", "Partners", "Marketplace", "Outbound"]
  end

  defp chart_page_bar_series do
    [
      %{label: "Orders", data: [124, 88, 96, 72], suffix: " orders"}
    ]
  end

  defp org_options do
    [
      %{name: "Suka Cipta", short: "SC", members: "12 members", current: true},
      %{name: "Pring Studio", short: "PS", members: "8 members", current: false},
      %{name: "Personal", short: "P", members: "1 members", current: false}
    ]
  end

  defp user_actions do
    [
      %{label: "Setting", icon: "hero-cog-6-tooth"},
      %{label: "Help", icon: "hero-question-mark-circle"},
      %{label: "Logout", icon: "hero-arrow-left-on-rectangle", variant: "destructive"}
    ]
  end

  defp org_switcher(assigns) do
    ~H"""
    <.menu_button
      id="layout-org-switcher"
      variant="unstyled"
      wrapper_class="block border-b border-border px-1 py-2"
      class="flex w-full items-center gap-2.5 rounded-lg border border-border bg-background px-2 py-1.5 text-left shadow-xs transition hover:bg-accent/60 group-data-[collapsed=true]/pui-layout:mx-auto group-data-[collapsed=true]/pui-layout:h-10 group-data-[collapsed=true]/pui-layout:w-10 group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:px-0"
      content_class="z-[60] min-w-64 rounded-lg border border-border bg-background p-1 shadow-lg"
    >
      <div class="grid h-8 w-8 shrink-0 place-items-center rounded-md bg-primary text-xs font-semibold text-primary-foreground">
        SC
      </div>
      <div class="min-w-0 flex-1 group-data-[collapsed=true]/pui-layout:hidden">
        <p class="truncate text-sm font-semibold text-foreground">Suka Cipta</p>
      </div>
      <.icon
        name="hero-chevron-up-down"
        class="size-4 text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden"
      />

      <:items>
        <div class="space-y-1">
          <p class="px-2 pt-2 pb-1 text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground">
            Organizations
          </p>

          <.menu_item
            :for={org <- org_options()}
            class="rounded-lg"
          >
            <span class="flex w-full items-center gap-3">
              <span class={[
                "grid h-7 w-7 shrink-0 place-items-center rounded-md text-[11px] font-semibold",
                org.current && "bg-primary text-primary-foreground",
                !org.current && "bg-muted text-foreground/80"
              ]}>
                {org.short}
              </span>
              <span class="min-w-0 flex-1 text-left">
                <span class="block truncate text-sm font-medium text-foreground">{org.name}</span>
                <span class="block truncate text-xs text-muted-foreground">{org.members}</span>
              </span>
              <.icon :if={org.current} name="hero-check" class="size-4 text-primary" />
            </span>
          </.menu_item>

          <.menu_separator />

          <button
            type="button"
            class="flex w-full items-center gap-2 rounded-lg px-2 py-2 text-sm font-medium text-primary transition hover:bg-accent"
          >
            <.icon name="hero-plus" class="size-4" /> Create new Org
          </button>
        </div>
      </:items>
    </.menu_button>
    """
  end

  defp user_menu(assigns) do
    ~H"""
    <.menu_button
      id="layout-user-menu"
      variant="unstyled"
      wrapper_class="block border-t border-border px-1 py-2 group-data-[collapsed=true]/pui-layout:px-1"
      class="flex w-full items-center gap-2.5 rounded-lg border border-border bg-background px-2 py-1.5 text-left shadow-xs transition hover:bg-accent/60 group-data-[collapsed=true]/pui-layout:mx-auto group-data-[collapsed=true]/pui-layout:h-10 group-data-[collapsed=true]/pui-layout:w-10 group-data-[collapsed=true]/pui-layout:justify-center group-data-[collapsed=true]/pui-layout:px-0"
      content_class="z-[60] min-w-56 rounded-lg border border-border bg-background p-1 shadow-lg"
    >
      <div class="grid h-8 w-8 shrink-0 place-items-center rounded-md bg-muted text-xs font-semibold text-foreground">
        S
      </div>
      <div class="min-w-0 flex-1 group-data-[collapsed=true]/pui-layout:hidden">
        <p class="truncate text-sm font-semibold text-foreground">Sucipto</p>
        <p class="truncate text-xs text-muted-foreground">Developer</p>
      </div>
      <.icon
        name="hero-chevron-up-down"
        class="size-4 text-muted-foreground group-data-[collapsed=true]/pui-layout:hidden"
      />

      <:items>
        <div class="space-y-1">
          <div class="rounded-lg px-2 py-2">
            <p class="text-sm font-medium text-foreground">Sucipto</p>
            <p class="text-xs text-muted-foreground">sucipto@sukacipta.com</p>
          </div>

          <.menu_separator />

          <.menu_item
            :for={action <- user_actions()}
            variant={action[:variant] || "default"}
            class="rounded-lg"
          >
            <.icon name={action.icon} class="size-4" />
            {action.label}
          </.menu_item>
        </div>
      </:items>
    </.menu_button>
    """
  end
end
