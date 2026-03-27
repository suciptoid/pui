defmodule AppWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality used by your application.
  """
  use AppWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="flex w-full items-center py-2 px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end

  @doc """
  Renders docs layout with sidebar navigation inspired by Tailwind CSS docs.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :live_action, :atom, required: true, doc: "the current live action"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def docs(assigns) do
    ~H"""
    <div class="flex h-screen bg-background">
      <%!-- Mobile Sidebar Overlay --%>
      <div
        id="mobile-sidebar-overlay"
        class="fixed inset-0 z-40 bg-black/50 lg:hidden hidden"
        phx-click={JS.hide(to: "#mobile-sidebar") |> JS.hide(to: "#mobile-sidebar-overlay")}
      />

      <%!-- Sidebar Navigation --%>
      <aside
        id="mobile-sidebar"
        class="fixed inset-y-0 left-0 z-50 w-72 bg-background border-r border-border lg:static lg:block hidden lg:overflow-y-auto"
      >
        <div class="flex h-full flex-col">
          <%!-- Logo Header --%>
          <div class="flex items-center justify-between border-b border-border px-6 py-4">
            <a href="/" class="flex items-center gap-3">
              <img src={~p"/images/pui-hook-2d.png"} width="36" />
              <div class="flex flex-col">
                <span class="text-lg font-bold text-foreground">PUI</span>
                <span class="text-xs text-muted-foreground">v1.0.0-alpha.10</span>
              </div>
            </a>
            <button
              class="lg:hidden p-2 rounded-md hover:bg-accent"
              phx-click={JS.hide(to: "#mobile-sidebar") |> JS.hide(to: "#mobile-sidebar-overlay")}
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <%!-- Search Bar --%>
          <div class="px-4 py-3 border-b border-border">
            <button
              class="w-full flex items-center gap-2 px-3 py-2 text-sm text-muted-foreground bg-muted/50 hover:bg-muted rounded-md transition-colors"
              onclick="document.dispatchEvent(new KeyboardEvent('keydown', {key: 'k', metaKey: true}))"
            >
              <.icon name="hero-magnifying-glass" class="size-4" />
              <span>Search documentation...</span>
              <span class="ml-auto text-xs border border-border rounded px-1.5 py-0.5">⌘K</span>
            </button>
          </div>

          <%!-- Navigation --%>
          <nav class="flex-1 overflow-y-auto p-4 space-y-6">
            <%!-- Getting Started --%>
            <.sidebar_group title="Getting Started" icon="hero-rocket-launch">
              <.sidebar_link navigate={~p"/"}>Home</.sidebar_link>
              <.sidebar_link
                patch={~p"/headless"}
                active={@live_action == :headless}
              >
                Headless Components
                <span class="ml-auto text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full">
                  New
                </span>
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Forms --%>
            <.sidebar_group title="Forms" icon="hero-document-text">
              <.sidebar_link patch={~p"/inputs"} active={@live_action == :inputs}>
                Inputs
              </.sidebar_link>
              <.sidebar_link patch={~p"/select"} active={@live_action == :select}>
                Select
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Actions --%>
            <.sidebar_group title="Actions" icon="hero-cursor-arrow-rays">
              <.sidebar_link patch={~p"/buttons"} active={@live_action == :buttons}>
                Buttons
              </.sidebar_link>
              <.sidebar_link patch={~p"/dropdown"} active={@live_action == :dropdown}>
                Dropdown
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Overlays --%>
            <.sidebar_group title="Overlays" icon="hero-squares-2x2">
              <.sidebar_link patch={~p"/dialog"} active={@live_action == :dialog}>
                Dialog
              </.sidebar_link>
              <.sidebar_link patch={~p"/popover"} active={@live_action == :popover}>
                Popover
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Feedback --%>
            <.sidebar_group title="Feedback" icon="hero-speaker-wave">
              <.sidebar_link patch={~p"/alert"} active={@live_action == :alert}>
                Alert
              </.sidebar_link>
              <.sidebar_link patch={~p"/toast"} active={@live_action == :toast}>
                Toast
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Layout --%>
            <.sidebar_group title="Layout" icon="hero-view-columns">
              <.sidebar_link patch={~p"/container"} active={@live_action == :container}>
                Container
              </.sidebar_link>
              <.sidebar_link patch={~p"/tab"} active={@live_action == :tab}>
                Tabs
              </.sidebar_link>
            </.sidebar_group>

            <%!-- Data Display --%>
            <.sidebar_group title="Data Display" icon="hero-chart-bar">
              <.sidebar_link patch={~p"/progress-badges"} active={@live_action == :progress_badges}>
                Progress & Badges
              </.sidebar_link>
            </.sidebar_group>
          </nav>

          <%!-- Footer Links --%>
          <div class="border-t border-border p-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <a
                  href="https://github.com/suciptoid/pui"
                  class="p-2 text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
                  target="_blank"
                >
                  <.icon name="hero-code-bracket" class="size-5" />
                </a>
              </div>
              <.theme_toggle />
            </div>
          </div>
        </div>
      </aside>

      <%!-- Main Content Area --%>
      <div class="flex flex-1 flex-col min-w-0 overflow-hidden">
        <%!-- Top Navigation Bar --%>
        <header class="flex items-center justify-between border-b border-border px-4 lg:px-8 py-3 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-30">
          <div class="flex items-center gap-4">
            <button
              class="lg:hidden p-2 -ml-2 rounded-md hover:bg-accent"
              phx-click={JS.show(to: "#mobile-sidebar") |> JS.show(to: "#mobile-sidebar-overlay")}
            >
              <.icon name="hero-bars-3" class="size-5" />
            </button>

            <%!-- Breadcrumbs --%>
            <nav aria-label="Breadcrumb" class="hidden md:flex items-center gap-2 text-sm">
              <.link
                navigate={~p"/"}
                class="text-muted-foreground hover:text-foreground transition-colors"
              >
                Home
              </.link>
              <.icon name="hero-chevron-right" class="size-4 text-muted-foreground" />
              <span class="font-medium text-foreground">{page_title(@live_action)}</span>
            </nav>
          </div>

          <div class="flex items-center gap-2">
            <a
              href="https://hexdocs.pm/pui"
              class="hidden sm:flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
              target="_blank"
            >
              <.icon name="hero-book-open" class="size-4" /> API
            </a>
            <a
              href="https://github.com/suciptoid/pui"
              class="flex items-center gap-2 px-3 py-1.5 text-sm font-medium bg-foreground text-background rounded-md hover:bg-foreground/90 transition-colors"
              target="_blank"
            >
              <.icon name="hero-star" class="size-4" />
              <span class="hidden sm:inline">Star on GitHub</span>
            </a>
          </div>
        </header>

        <%!-- Content Scroll Area --%>
        <div class="flex flex-1 overflow-hidden">
          <%!-- Main Documentation Content --%>
          <main class="flex-1 overflow-y-auto">
            <div class="mx-auto max-w-4xl px-4 lg:px-8 py-8 lg:py-12">
              <%!-- Page Title --%>
              <div class="mb-8">
                <h1 class="text-3xl lg:text-4xl font-bold tracking-tight text-foreground mb-3">
                  {page_title(@live_action)}
                </h1>
                <p class="text-lg text-muted-foreground">
                  {page_description(@live_action)}
                </p>
              </div>

              <%!-- Content --%>
              <div class="prose prose-zinc dark:prose-invert max-w-none">
                {render_slot(@inner_block)}
              </div>

              <%!-- Page Footer --%>
              <footer class="mt-16 pt-8 border-t border-border">
                <div class="flex items-center justify-between">
                  <p class="text-sm text-muted-foreground">
                    © 2026 PUI Components. Built with <span class="text-red-500">♥</span>
                    using Phoenix LiveView.
                  </p>
                  <a
                    href="https://github.com/suciptoid/pui"
                    class="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    Edit this page on GitHub
                  </a>
                </div>
              </footer>
            </div>
          </main>

          <%!-- Right Sidebar - Table of Contents (On This Page) --%>
          <aside class="hidden xl:block w-64 overflow-y-auto border-l border-border bg-background px-6 py-8">
            <div class="sticky top-8">
              <h5 class="mb-3 text-sm font-semibold text-foreground">On this page</h5>
              <ul class="space-y-2 text-sm">
                <li>
                  <a
                    href="#"
                    class="block text-muted-foreground hover:text-foreground transition-colors"
                  >
                    Overview
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="block text-muted-foreground hover:text-foreground transition-colors"
                  >
                    Examples
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="block text-muted-foreground hover:text-foreground transition-colors"
                  >
                    API Reference
                  </a>
                </li>
              </ul>

              <div class="mt-8 pt-8 border-t border-border">
                <h5 class="mb-3 text-sm font-semibold text-foreground">Related</h5>
                <ul class="space-y-2 text-sm">
                  <li>
                    <a
                      href="/guides/headless-usage.md"
                      class="block text-muted-foreground hover:text-foreground transition-colors"
                    >
                      Headless Usage Guide
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </div>
    """
  end

  # Sidebar Components

  attr :title, :string, required: true
  attr :icon, :string, default: nil
  slot :inner_block, required: true

  defp sidebar_group(assigns) do
    ~H"""
    <div class="sidebar-group">
      <div class="flex items-center gap-2 px-3 py-2 mb-1">
        <.icon :if={@icon} name={@icon} class="size-4 text-muted-foreground" />
        <h3 class="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
          {@title}
        </h3>
      </div>
      <ul class="space-y-0.5">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  attr :patch, :string, default: nil
  attr :navigate, :string, default: nil
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp sidebar_link(assigns) do
    ~H"""
    <li>
      <.link
        patch={@patch}
        navigate={@navigate}
        class={[
          "flex items-center justify-between px-3 py-1.5 text-sm rounded-md transition-colors",
          @active && "bg-accent text-accent-foreground font-medium",
          !@active && "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
        ]}
      >
        {render_slot(@inner_block)}
      </.link>
    </li>
    """
  end

  # Page metadata

  defp page_title(:index), do: "Overview"
  defp page_title(:headless), do: "Headless Components"
  defp page_title(:inputs), do: "Inputs"
  defp page_title(:buttons), do: "Buttons"
  defp page_title(:dropdown), do: "Dropdown"
  defp page_title(:select), do: "Select"
  defp page_title(:popover), do: "Popover"
  defp page_title(:toast), do: "Toast"
  defp page_title(:container), do: "Container"
  defp page_title(:dialog), do: "Dialog"
  defp page_title(:progress_badges), do: "Progress & Badges"
  defp page_title(:alert), do: "Alert"
  defp page_title(:tab), do: "Tabs"
  defp page_title(_), do: "Components"

  defp page_description(:index),
    do: "A comprehensive collection of Phoenix LiveView components built with Tailwind CSS."

  defp page_description(:headless),
    do:
      "Build custom UI components with full control over styling while preserving accessibility and behavior."

  defp page_description(:buttons),
    do: "Interactive button components with multiple variants, sizes, and states."

  defp page_description(:inputs),
    do: "Form input components including text fields, checkboxes, radio buttons, and switches."

  defp page_description(:select),
    do: "Dropdown selection components with search, grouping, and keyboard navigation support."

  defp page_description(:dropdown),
    do: "Menu dropdowns with items, shortcuts, separators, and destructive actions."

  defp page_description(:dialog),
    do: "Modal dialogs for confirmations, forms, and complex interactions."

  defp page_description(:popover),
    do: "Floating popovers using Floating UI for precise positioning."

  defp page_description(:alert),
    do: "Alert components for displaying important messages and status updates."

  defp page_description(:toast),
    do: "Toast notifications with beautiful animations and stacking support."

  defp page_description(:container),
    do: "Layout containers for structuring your application's UI."

  defp page_description(:tab),
    do: "Tab navigation components for organizing content into sections."

  defp page_description(:progress_badges),
    do: "Progress bars and badge components for status indicators."

  defp page_description(_), do: ""

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
