defmodule AppWeb.Live.DocsLive do
  @moduledoc """
  LiveView for rendering documentation pages with interactive component demos.

  Loads markdown documentation from NimblePublisher and renders interactive
  PUI component examples alongside the prose content.
  """
  use AppWeb, :live_view
  use PUI

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    docs = App.Docs.grouped_docs()
    seo = AppWeb.Seo.docs_index_meta()

    {:ok,
     socket
     |> assign(docs: docs)
     |> assign(form: to_form(%{"name" => "", "email" => "", "select" => ""}))
     |> assign(page_title: seo.title, seo: seo)
     |> assign(
       btn_variant: "default",
       btn_size: "default",
       show_dialog: false,
       progress_value: 45.0,
       toast_count: 0,
       flash_position: "top-right"
     )}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    doc = App.Docs.get_doc!(slug)
    seo = AppWeb.Seo.doc_meta(doc)

    {:noreply,
     socket
     |> assign(doc: doc, page_title: seo.title, seo: seo)
     |> assign(live_action: :show)}
  end

  def handle_params(_params, _uri, socket) do
    docs = App.Docs.all_docs()

    # Prefer the `getting-started` doc as the primary docs entry when available.
    preferred = Enum.find(docs, &(&1.id == "getting-started"))
    target = preferred || List.first(docs)

    if target do
      Logger.info("Docs redirect target: #{target.id}")
      {:noreply, push_navigate(socket, to: ~p"/docs/#{target.id}")}
    else
      seo = AppWeb.Seo.docs_index_meta()
      {:noreply, assign(socket, doc: nil, page_title: seo.title, seo: seo, live_action: :index)}
    end
  end

  @impl true
  def handle_event("select_variant", %{"variant" => variant}, socket) do
    {:noreply, assign(socket, btn_variant: variant)}
  end

  def handle_event("select_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, btn_size: size)}
  end

  def handle_event("toggle_dialog", _params, socket) do
    {:noreply, assign(socket, show_dialog: !socket.assigns.show_dialog)}
  end

  def handle_event("close_dialog", _params, socket) do
    {:noreply, assign(socket, show_dialog: false)}
  end

  def handle_event("send_toast", _params, socket) do
    count = socket.assigns.toast_count + 1
    PUI.Flash.send_flash("Toast notification ##{count}!")
    {:noreply, assign(socket, toast_count: count)}
  end

  def handle_event("select_flash_position", %{"position" => position}, socket) do
    {:noreply, assign(socket, flash_position: position)}
  end

  def handle_event("update_progress", %{"value" => value}, socket) do
    val =
      case Float.parse(value) do
        {v, _} -> v
        :error -> socket.assigns.progress_value
      end

    {:noreply, assign(socket, progress_value: val)}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, form: to_form(params))}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("add-new-item", _params, socket) do
    PUI.Flash.send_flash("Add new item clicked!")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.docs_shell docs={@docs} doc={@doc} flash={@flash} flash_position={@flash_position}>
      <div :if={@doc} class="space-y-12">
        <%!-- Page Header --%>
        <div class="border-b border-border pb-8">
          <div class="flex items-center gap-2 text-sm text-muted-foreground mb-3">
            <span>{@doc.group}</span>
            <.icon name="hero-chevron-right-mini" class="size-3.5" />
            <span class="text-foreground font-medium">{@doc.title}</span>
          </div>
          <h1 class="text-4xl font-bold tracking-tight text-foreground">{@doc.title}</h1>
          <p class="mt-3 text-lg text-muted-foreground max-w-2xl">{@doc.description}</p>
        </div>

        <%!-- Interactive Demos --%>
        <.live_demos slug={@doc.id} assigns={assigns} />

        <%!-- Markdown Documentation --%>
        <article class="prose prose-zinc dark:prose-invert max-w-none prose-headings:scroll-mt-24 prose-a:text-primary hover:prose-a:text-primary/80 prose-pre:rounded-xl prose-pre:border prose-pre:border-border prose-code:before:content-none prose-code:after:content-none">
          {raw(@doc.body)}
        </article>
      </div>
    </.docs_shell>
    """
  end

  # ── Docs shell layout ──────────────────────────────────────────────────

  attr :docs, :list, required: true
  attr :doc, :any, default: nil
  attr :flash, :map, required: true
  attr :flash_position, :string, default: "top-right"
  slot :inner_block, required: true

  defp docs_shell(assigns) do
    ~H"""
    <div class="flex min-h-screen bg-background">
      <PUI.Flash.flash_group flash={@flash} live={true} position={@flash_position} />

      <%!-- Mobile Sidebar Overlay --%>
      <div
        id="docs-mobile-overlay"
        class="fixed inset-0 z-40 bg-black/50 lg:hidden hidden"
        phx-click={JS.hide(to: "#docs-mobile-sidebar") |> JS.hide(to: "#docs-mobile-overlay")}
      />

      <%!-- Sidebar --%>
      <aside
        id="docs-mobile-sidebar"
        class="fixed inset-y-0 left-0 z-50 w-72 bg-background border-r border-border lg:sticky lg:top-0 lg:block hidden lg:h-screen lg:overflow-y-auto lg:shrink-0"
      >
        <div class="flex h-full flex-col">
          <%!-- Logo --%>
          <div class="flex h-16 shrink-0 items-center justify-between border-b border-border px-5">
            <.link navigate={~p"/"} class="flex items-center gap-3 group">
              <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
                <.icon name="hero-cube" class="size-4" />
              </div>
              <div class="flex flex-col">
                <span class="text-base font-bold text-foreground">PUI</span>
                <span class="text-[10px] leading-none text-zinc-600 dark:text-zinc-400">
                  Documentation
                </span>
              </div>
            </.link>
            <button
              class="lg:hidden rounded-md p-1.5 text-zinc-600 hover:bg-accent dark:text-zinc-300"
              phx-click={JS.hide(to: "#docs-mobile-sidebar") |> JS.hide(to: "#docs-mobile-overlay")}
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <%!-- Navigation --%>
          <nav class="flex-1 overflow-y-auto p-4 space-y-6">
            <div :for={{group, docs} <- @docs}>
              <h3 class="mb-1 flex items-center gap-2 px-3 py-2 text-xs font-semibold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                <.icon name={group_icon(group)} class="size-3.5" />
                {group}
              </h3>
              <ul class="space-y-0.5">
                <li :for={d <- docs}>
                  <.link
                    navigate={~p"/docs/#{d.id}"}
                    class={[
                      "flex items-center px-3 py-1.5 text-sm rounded-md transition-all duration-150",
                      @doc && @doc.id == d.id &&
                        "bg-primary/10 text-primary font-medium",
                      !(@doc && @doc.id == d.id) &&
                        "text-zinc-700 hover:bg-accent/60 hover:text-zinc-950 dark:text-zinc-300 dark:hover:text-white"
                    ]}
                  >
                    {d.title}
                  </.link>
                </li>
              </ul>
            </div>
          </nav>
        </div>
      </aside>

      <%!-- Main --%>
      <div class="flex flex-1 flex-col min-w-0">
        <%!-- Top bar --%>
        <header class="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-border bg-background/95 px-4 backdrop-blur supports-[backdrop-filter]:bg-background/60 lg:px-8">
          <div class="flex items-center gap-4">
            <button
              class="lg:hidden p-2 -ml-2 rounded-md hover:bg-accent"
              phx-click={JS.show(to: "#docs-mobile-sidebar") |> JS.show(to: "#docs-mobile-overlay")}
            >
              <.icon name="hero-bars-3" class="size-5" />
            </button>
            <span class="text-sm font-medium text-foreground">Documentation</span>
          </div>
          <div class="flex items-center gap-3">
            <a
              href={website_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="hidden md:flex items-center gap-1.5 px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
            >
              <.icon name="hero-globe-alt" class="size-4" /> Website
            </a>
            <a
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
            >
              <.icon name="hero-code-bracket" class="size-4" /> Source Code
            </a>
            <a
              href="https://hexdocs.pm/pui"
              target="_blank"
              class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
            >
              <.icon name="hero-book-open" class="size-4" /> HexDocs
            </a>
            <Layouts.theme_toggle />
          </div>
        </header>

        <%!-- Content + TOC --%>
        <div class="flex flex-1 min-h-0">
          <main class="flex-1 overflow-y-auto" id="docs-main-content">
            <div class="mx-auto max-w-4xl px-4 lg:px-8 py-8 lg:py-12">
              {render_slot(@inner_block)}

              <footer class="mt-16 pt-8 border-t border-border">
                <div class="flex items-center justify-between text-sm text-muted-foreground">
                  <p>
                    © 2026 PUI. Built with <span class="text-red-500">♥</span> and Phoenix LiveView.
                  </p>
                  <.link navigate={~p"/"} class="transition-colors hover:text-foreground">
                    Back to home →
                  </.link>
                </div>
              </footer>
            </div>
          </main>

          <%!-- TOC --%>
          <aside
            :if={@doc && @doc.toc != []}
            class="hidden xl:block w-56 shrink-0 self-start border-l border-border bg-background sticky top-8"
          >
            <div class="sticky top-0 max-h-screen overflow-y-auto px-5 py-8">
              <h5 class="mb-3 text-xs font-semibold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                On this page
              </h5>
              <ul class="space-y-1.5">
                <li :for={item <- @doc.toc}>
                  <a
                    href={"##{item.id}"}
                    class={[
                      "block text-sm text-zinc-600 transition-colors hover:text-zinc-950 dark:text-zinc-300 dark:hover:text-white",
                      item.level == 3 && "pl-3"
                    ]}
                  >
                    {item.text}
                  </a>
                </li>
              </ul>
            </div>
          </aside>
        </div>
      </div>
    </div>
    """
  end

  # ── Interactive demos per component ─────────────────────────────────────

  attr :slug, :string, required: true
  attr :assigns, :map, required: true

  defp live_demos(%{slug: "button"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <%!-- Playground --%>
      <div class="rounded-xl border border-border bg-background shadow-sm">
        <div class="rounded-t-xl bg-muted/30 px-5 py-3 border-b border-border">
          <h3 class="text-sm font-medium text-foreground">Playground</h3>
        </div>
        <div class="rounded-b-xl p-6 flex flex-col gap-6 overflow-visible">
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Variant
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={
                  v <-
                    ~w(default secondary destructive outline ghost link)
                }
                type="button"
                phx-click="select_variant"
                phx-value-variant={v}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  v == @assigns.btn_variant &&
                    "bg-primary text-primary-foreground shadow-sm",
                  v != @assigns.btn_variant &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {v}
              </button>
            </div>
          </div>
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Size
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={s <- ~w(sm default lg icon)}
                type="button"
                phx-click="select_size"
                phx-value-size={s}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  s == @assigns.btn_size &&
                    "bg-primary text-primary-foreground shadow-sm",
                  s != @assigns.btn_size &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {s}
              </button>
            </div>
          </div>
          <div class="flex items-center justify-center py-8 rounded-lg bg-muted/20 border border-dashed border-border">
            <.button variant={@assigns.btn_variant} size={@assigns.btn_size}>
              {if @assigns.btn_size == "icon", do: "🔔", else: "Button"}
            </.button>
          </div>
        </div>
      </div>

      <%!-- Variants showcase --%>
      <.demo_section title="All Variants" id="all-variants">
        <div class="flex flex-wrap items-center gap-3">
          <.button variant="default">Default</.button>
          <.button variant="secondary">Secondary</.button>
          <.button variant="destructive">Destructive</.button>
          <.button variant="outline">Outline</.button>
          <.button variant="ghost">Ghost</.button>
          <.button variant="link">Link</.button>
        </div>
      </.demo_section>

      <%!-- Sizes showcase --%>
      <.demo_section title="Sizes" id="sizes">
        <div class="flex flex-wrap items-center gap-3">
          <.button size="sm">Small</.button>
          <.button size="default">Default</.button>
          <.button size="lg">Large</.button>
          <.button size="icon">
            <.icon name="hero-bell" class="size-4" />
          </.button>
        </div>
      </.demo_section>

      <%!-- With icons --%>
      <.demo_section title="With Icons" id="with-icons">
        <div class="flex flex-wrap items-center gap-3">
          <.button>
            <.icon name="hero-plus" class="size-4 mr-2" /> Add Item
          </.button>
          <.button variant="destructive">
            <.icon name="hero-trash" class="size-4 mr-2" /> Delete
          </.button>
          <.button variant="outline">
            <.icon name="hero-arrow-down-tray" class="size-4 mr-2" /> Download
          </.button>
        </div>
      </.demo_section>

      <%!-- Disabled --%>
      <.demo_section title="Disabled" id="disabled">
        <div class="flex flex-wrap items-center gap-3">
          <.button disabled>Disabled</.button>
          <.button variant="secondary" disabled>Disabled</.button>
          <.button variant="outline" disabled>Disabled</.button>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "headless"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Unstyled Button and Menu" id="unstyled-button-and-menu">
        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <div class="flex flex-wrap items-start gap-4">
            <.button
              variant="unstyled"
              class="inline-flex items-center rounded-xl bg-zinc-950 px-4 py-2 text-sm font-medium text-white shadow-sm transition-colors hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200"
            >
              Custom Trigger
            </.button>

            <.menu_button
              variant="unstyled"
              class="inline-flex items-center gap-2 rounded-xl border border-primary/30 bg-primary/10 px-4 py-2 text-sm font-medium text-primary transition-colors hover:bg-primary/15"
              content_class="aria-hidden:hidden block min-w-48 rounded-xl border border-border bg-background p-1 shadow-xl"
            >
              Custom Menu
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
                <.icon name="hero-user" class="size-4" /> Profile
              </:item>
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
                <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
              </:item>
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-destructive transition-colors hover:bg-destructive/10">
                <.icon name="hero-trash" class="size-4" /> Delete
              </:item>
            </.menu_button>
          </div>

          <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
            <p class="font-medium text-foreground">What PUI still handles</p>
            <ul class="mt-3 space-y-2">
              <li>ARIA attributes and keyboard navigation</li>
              <li>Popover positioning, dismissal, and focus behavior</li>
              <li>Slot-based composition for items and triggers</li>
            </ul>
          </div>
        </div>
      </.demo_section>

      <.demo_section title="Low-level Popover Hook" id="low-level-popover-hook">
        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <.popover_base
            id="docs-headless-popover"
            class="w-fit"
            phx-hook="PUI.Popover"
            data-placement="bottom-start"
          >
            <:trigger class="inline-flex items-center gap-2 rounded-xl border border-border bg-background px-4 py-2 text-sm font-medium text-foreground shadow-sm transition-colors hover:bg-accent">
              <.icon name="hero-code-bracket" class="size-4" /> Open custom popover
            </:trigger>
            <:popup class="aria-hidden:hidden block w-72 rounded-2xl border border-border bg-background p-4 shadow-xl">
              <div class="space-y-3">
                <span class="inline-flex rounded-full bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
                  Level 1
                </span>
                <h3 class="text-sm font-semibold text-foreground">Low-level hook example</h3>
                <p class="text-sm text-muted-foreground">
                  This example uses <code>popover_base</code>
                  directly so you control the trigger markup,
                  popup container, and every utility class yourself.
                </p>
              </div>
            </:popup>
          </.popover_base>

          <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
            <p class="font-medium text-foreground">When to use this</p>
            <ul class="mt-3 space-y-2">
              <li>Building a custom design system on top of PUI behavior</li>
              <li>Reusing Floating UI positioning with your own markup</li>
              <li>Creating bespoke popovers, menus, or tooltips</li>
            </ul>
          </div>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "input"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Text Inputs" id="text-inputs">
        <div class="max-w-sm space-y-4">
          <.input id="demo-text" name="demo-text" label="Full Name" placeholder="John Doe" />
          <.input
            id="demo-email"
            name="demo-email"
            type="email"
            label="Email"
            placeholder="you@example.com"
          />
          <.input
            id="demo-password"
            name="demo-password"
            type="password"
            label="Password"
            placeholder="••••••••"
          />
          <.input
            id="demo-number"
            name="demo-number"
            type="number"
            label="Quantity"
            placeholder="12"
            min="0"
          />
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "textarea"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Textareas" id="basic-textareas">
        <div class="max-w-xl space-y-4">
          <.textarea
            id="demo-bio"
            name="bio"
            label="Biography"
            placeholder="Tell us about yourself..."
            rows="4"
          />

          <.textarea
            id="demo-feedback"
            name="feedback"
            label="Team Feedback"
            placeholder="Share context, blockers, or ideas..."
            rows="6"
          />
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "checkbox"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Checkbox States" id="checkbox-states">
        <div class="space-y-4">
          <.checkbox id="demo-terms" name="terms" label="I agree to the terms and conditions" />
          <.checkbox id="demo-newsletter" name="newsletter" label="Subscribe to newsletter" checked />
          <.checkbox id="demo-disabled-checkbox" name="disabled" label="Disabled checkbox" disabled />
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "radio"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Radio Group" id="radio-group">
        <div class="space-y-3">
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-starter" name="demo-plan" value="starter" checked />
            <span class="text-sm text-foreground">Starter</span>
          </label>
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-pro" name="demo-plan" value="pro" />
            <span class="text-sm text-foreground">Pro</span>
          </label>
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-enterprise" name="demo-plan" value="enterprise" />
            <span class="text-sm text-foreground">Enterprise</span>
          </label>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "switch"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Switches" id="switches">
        <div class="space-y-4">
          <.switch id="demo-notifications" name="notifications" label="Enable notifications" />
          <.switch id="demo-marketing" name="marketing" label="Receive product updates" />
          <.switch id="demo-disabled-switch" name="disabled-switch" label="Disabled switch" disabled />
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "select"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Select" id="basic-select">
        <div class="max-w-sm">
          <.select
            id="demo-basic"
            name="demo-basic"
            label="Favorite Fruit"
            options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
          />
        </div>
      </.demo_section>

      <.demo_section title="Searchable" id="searchable">
        <div class="max-w-sm">
          <.select
            id="demo-search"
            name="demo-search"
            label="Search Countries"
            placeholder="Type to search..."
            searchable={true}
            options={[
              "Argentina",
              "Brazil",
              "Canada",
              "Denmark",
              "Egypt",
              "France",
              "Germany",
              "India",
              "Japan"
            ]}
          />
        </div>
      </.demo_section>

      <.demo_section title="Grouped Options" id="grouped-options">
        <div class="max-w-sm">
          <.select
            id="demo-grouped"
            name="demo-grouped"
            label="Select Food"
            searchable={true}
            options={[
              {"Fruits", ["Apple", "Banana", "Cherry"]},
              {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}, {"tomato", "Tomato"}]}
            ]}
          />
        </div>
      </.demo_section>

      <.demo_section title="Custom Items with Icons" id="custom-items">
        <div class="max-w-sm">
          <.select id="demo-custom" name="demo-custom" label="Select Action">
            <.select_item value="edit">
              <.icon name="hero-pencil" class="size-4" /> Edit
            </.select_item>
            <.select_item value="duplicate">
              <.icon name="hero-document-duplicate" class="size-4" /> Duplicate
            </.select_item>
            <.select_item value="archive">
              <.icon name="hero-archive-box" class="size-4" /> Archive
            </.select_item>
          </.select>
        </div>
      </.demo_section>

      <.demo_section title="With Footer" id="select-footer">
        <div class="max-w-sm">
          <.select id="demo-footer" name="demo-footer" label="Items" searchable={true}>
            <.select_item value="item-1">Item One</.select_item>
            <.select_item value="item-2">Item Two</.select_item>
            <.select_item value="item-3">Item Three</.select_item>
            <:footer>
              <div class="border-t border-border p-2">
                <button
                  type="button"
                  phx-click="add-new-item"
                  class="flex items-center gap-2 text-sm text-primary hover:text-primary/80"
                >
                  <.icon name="hero-plus" class="size-4" /> Add New Item
                </button>
              </div>
            </:footer>
          </.select>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "dialog"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Dialog" id="basic-dialog">
        <.dialog :let={%{hide: hide}} id="demo-dialog" size="md">
          <:trigger :let={attr}>
            <.button {attr}>Open Dialog</.button>
          </:trigger>

          <div class="space-y-4">
            <div>
              <h2 class="text-lg font-semibold">Dialog Title</h2>
              <p class="mt-1 text-sm text-muted-foreground">
                This is a demonstration of the PUI dialog component.
              </p>
            </div>
            <p class="text-sm text-muted-foreground">
              Dialogs are useful for confirmations, forms, and complex interactions that require user attention.
            </p>
            <div class="flex justify-end gap-2 pt-2">
              <.button variant="outline" phx-click={hide}>
                Cancel
              </.button>
              <.button phx-click={hide}>Confirm</.button>
            </div>
          </div>
        </.dialog>
      </.demo_section>

      <.demo_section title="Dialog Sizes" id="dialog-sizes">
        <div class="flex flex-wrap gap-3">
          <.dialog :let={%{hide: hide}} id="demo-sm" size="sm">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Small</.button>
            </:trigger>

            <p class="text-sm">This is a small dialog.</p>
            <div class="mt-4 flex justify-end">
              <.button size="sm" phx-click={hide}>
                Close
              </.button>
            </div>
          </.dialog>

          <.dialog :let={%{hide: hide}} id="demo-lg" size="lg">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Large</.button>
            </:trigger>

            <p class="text-sm">This is a large dialog with more room for content.</p>
            <div class="mt-4 flex justify-end">
              <.button phx-click={hide}>
                Close
              </.button>
            </div>
          </.dialog>

          <.dialog :let={%{hide: hide}} id="demo-xl" size="xl">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Extra Large</.button>
            </:trigger>

            <p class="text-sm">This is an extra large dialog for complex content.</p>
            <div class="mt-4 flex justify-end">
              <.button phx-click={hide}>
                Close
              </.button>
            </div>
          </.dialog>
        </div>
      </.demo_section>

      <.demo_section title="Alert Dialog" id="alert-dialog">
        <.dialog :let={%{hide: hide}} id="demo-alert" alert={true} size="sm">
          <:trigger :let={attr}>
            <.button variant="destructive" {attr}>Delete Item</.button>
          </:trigger>

          <div class="space-y-3">
            <h2 class="text-lg font-semibold text-destructive">Are you sure?</h2>
            <p class="text-sm text-muted-foreground">
              This action cannot be undone. This will permanently delete the item.
            </p>
            <div class="flex justify-end gap-2 pt-2">
              <.button variant="outline" phx-click={hide}>
                Cancel
              </.button>
              <.button variant="destructive" phx-click={hide}>
                Delete
              </.button>
            </div>
          </div>
        </.dialog>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "dropdown"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Dropdown" id="basic-dropdown">
        <.menu_button>
          Actions
          <:item>Edit</:item>
          <:item>Duplicate</:item>
          <:item>Archive</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="With Shortcuts" id="shortcuts">
        <.menu_button>
          File
          <:item shortcut="⌘N">New File</:item>
          <:item shortcut="⌘O">Open</:item>
          <:item shortcut="⌘S">Save</:item>
          <:item shortcut="⇧⌘S">Save As</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="Destructive Actions" id="destructive-dropdown">
        <.menu_button>
          Manage
          <:item>Settings</:item>
          <:item>Export Data</:item>
          <:item variant="destructive">Delete Account</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="Button Variants" id="dropdown-variants">
        <div class="flex flex-wrap gap-3">
          <.menu_button variant="default">
            Default
            <:item>Item 1</:item>
            <:item>Item 2</:item>
          </.menu_button>
          <.menu_button variant="outline">
            Outline
            <:item>Item 1</:item>
            <:item>Item 2</:item>
          </.menu_button>
          <.menu_button variant="ghost">
            Ghost
            <:item>Item 1</:item>
            <:item>Item 2</:item>
          </.menu_button>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "popover"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Popover" id="basic-popover">
        <.popover_base
          id="demo-popover"
          class="w-fit"
          phx-hook="PUI.Popover"
          data-placement="bottom"
        >
          <:trigger class="inline-flex h-9 items-center justify-center gap-2 whitespace-nowrap rounded-md border border-input bg-transparent px-4 py-2 text-sm font-medium shadow-xs transition-[color,box-shadow] hover:bg-accent hover:text-accent-foreground">
            Show Popover
          </:trigger>
          <:popup class="aria-hidden:hidden block min-w-[250px] rounded-md border border-border bg-popover p-4 text-popover-foreground shadow-md z-50">
            <div class="p-4 space-y-2 w-64">
              <h3 class="font-semibold text-sm">Popover Title</h3>
              <p class="text-sm text-muted-foreground">
                This is a popover with some helpful content. Click the button again to close.
              </p>
            </div>
          </:popup>
        </.popover_base>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "tooltip"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Tooltip Placements" id="tooltip-placements">
        <div class="flex flex-wrap items-center gap-6">
          <.tooltip placement="top">
            <.button variant="outline" size="sm">Top</.button>
            <:tooltip>Tooltip on top</:tooltip>
          </.tooltip>
          <.tooltip placement="bottom">
            <.button variant="outline" size="sm">Bottom</.button>
            <:tooltip>Tooltip on bottom</:tooltip>
          </.tooltip>
          <.tooltip placement="left">
            <.button variant="outline" size="sm">Left</.button>
            <:tooltip>Tooltip on left</:tooltip>
          </.tooltip>
          <.tooltip placement="right">
            <.button variant="outline" size="sm">Right</.button>
            <:tooltip>Tooltip on right</:tooltip>
          </.tooltip>
        </div>
      </.demo_section>

      <.demo_section title="Rich Tooltip" id="rich-tooltip">
        <.tooltip id="docs-rich-tooltip" placement="bottom">
          <.button variant="outline">Hover for details</.button>
          <:tooltip>
            <div class="w-56 space-y-2">
              <p class="text-sm font-medium">Tooltip content</p>
              <p class="text-xs text-muted-foreground">
                Tooltips can hold short, contextual guidance without taking over the layout.
              </p>
            </div>
          </:tooltip>
        </.tooltip>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "alert"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Default Alert" id="default-alert">
        <.alert>
          <:icon><.icon name="hero-information-circle" class="size-5" /></:icon>
          <:title>Heads up!</:title>
          <:description>You can add components to your app using the CLI.</:description>
        </.alert>
      </.demo_section>

      <.demo_section title="Destructive Alert" id="destructive-alert">
        <.alert variant="destructive">
          <:icon><.icon name="hero-exclamation-triangle" class="size-5" /></:icon>
          <:title>Error</:title>
          <:description>Something went wrong. Please try again later.</:description>
        </.alert>
      </.demo_section>

      <.demo_section title="Custom Content" id="custom-alert">
        <.alert>
          <div class="flex items-center gap-3">
            <.icon name="hero-check-circle" class="size-5 text-green-500" />
            <div>
              <p class="font-semibold text-sm">Success!</p>
              <p class="text-sm text-muted-foreground">Your changes have been saved successfully.</p>
            </div>
          </div>
        </.alert>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "flash"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Send Toast" id="send-toast">
        <div class="space-y-6">
          <div class="flex flex-wrap items-center gap-2">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Position
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={
                  position <- ~w(top-left top-center top-right bottom-left bottom-center bottom-right)
                }
                type="button"
                phx-click="select_flash_position"
                phx-value-position={position}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  position == @assigns.flash_position &&
                    "bg-primary text-primary-foreground shadow-sm",
                  position != @assigns.flash_position &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {position}
              </button>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <.button phx-click="send_toast">
              <.icon name="hero-bell" class="size-4 mr-2" /> Send Toast
            </.button>
            <p class="text-sm text-muted-foreground self-center">
              Position: {@assigns.flash_position}. Count: {@assigns.toast_count}
            </p>
          </div>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "container"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Card" id="card-demo">
        <PUI.Container.card class="max-w-md">
          <PUI.Container.card_header>
            <PUI.Container.card_title>Card Title</PUI.Container.card_title>
            <PUI.Container.card_description>
              This is a card description.
            </PUI.Container.card_description>
          </PUI.Container.card_header>
          <PUI.Container.card_content>
            <p class="text-sm text-muted-foreground">
              The card component is a versatile container for grouping related content.
            </p>
          </PUI.Container.card_content>
          <PUI.Container.card_footer class="flex justify-end gap-2">
            <.button variant="outline" size="sm">Cancel</.button>
            <.button size="sm">Save</.button>
          </PUI.Container.card_footer>
        </PUI.Container.card>
      </.demo_section>

      <.demo_section title="Card with Action" id="card-action-demo">
        <PUI.Container.card class="max-w-md">
          <PUI.Container.card_header>
            <PUI.Container.card_title>Team Members</PUI.Container.card_title>
            <PUI.Container.card_description>Manage your team.</PUI.Container.card_description>
            <PUI.Container.card_action>
              <.button size="sm" variant="outline">
                <.icon name="hero-plus" class="size-4 mr-1" /> Add
              </.button>
            </PUI.Container.card_action>
          </PUI.Container.card_header>
          <PUI.Container.card_content>
            <div class="space-y-2">
              <div class="flex items-center gap-3 py-2">
                <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                  A
                </div>
                <div>
                  <p class="text-sm font-medium">Alice</p>
                  <p class="text-xs text-muted-foreground">alice@example.com</p>
                </div>
              </div>
              <div class="flex items-center gap-3 py-2">
                <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                  B
                </div>
                <div>
                  <p class="text-sm font-medium">Bob</p>
                  <p class="text-xs text-muted-foreground">bob@example.com</p>
                </div>
              </div>
            </div>
          </PUI.Container.card_content>
        </PUI.Container.card>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "loading"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Loading Topbar" id="loading-demo">
        <p class="text-sm text-muted-foreground">
          The loading topbar is already active on this page! Navigate between docs pages to see it in action.
          Look at the top of the page during navigation.
        </p>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "progress-badges"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Progress Bar" id="progress-demo">
        <div class="space-y-4 max-w-md">
          <.progress value={@assigns.progress_value} />
          <div class="flex items-center gap-3">
            <input
              type="range"
              min="0"
              max="100"
              value={@assigns.progress_value}
              phx-change="update_progress"
              name="value"
              class="flex-1"
            />
            <span class="text-sm font-mono text-muted-foreground w-12 text-right">
              {trunc(@assigns.progress_value)}%
            </span>
          </div>
        </div>
      </.demo_section>

      <.demo_section title="Badges" id="badges-demo">
        <div class="flex flex-wrap items-center gap-3">
          <.badge>Default</.badge>
          <.badge variant="secondary">Secondary</.badge>
          <.badge variant="destructive">Destructive</.badge>
          <.badge variant="outline">Outline</.badge>
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(%{slug: "getting-started"} = assigns) do
    ~H"""
    <section class="space-y-8">
      <.demo_section title="Quick Example" id="quick-example">
        <div class="flex flex-wrap items-center gap-3">
          <.button>Primary Button</.button>
          <.button variant="secondary">Secondary</.button>
          <.button variant="outline">Outline</.button>
        </div>
        <div class="mt-4 max-w-sm">
          <.input id="quick-input" name="quick" label="Sample Input" placeholder="Type here..." />
        </div>
      </.demo_section>
    </section>
    """
  end

  defp live_demos(assigns) do
    ~H"""
    """
  end

  # ── Helper components ───────────────────────────────────────────────────

  attr :title, :string, required: true
  attr :id, :string, required: true
  slot :inner_block, required: true

  defp demo_section(assigns) do
    ~H"""
    <div class="rounded-xl border border-border bg-background shadow-sm overflow-visible" id={@id}>
      <div class="rounded-t-xl bg-muted/30 px-5 py-3 border-b border-border">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
      </div>
      <div class="rounded-b-xl p-6 bg-background overflow-visible">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # ── Icon mapping ────────────────────────────────────────────────────────

  defp group_icon("Getting Started"), do: "hero-rocket-launch"
  defp group_icon("Forms"), do: "hero-document-text"
  defp group_icon("Actions"), do: "hero-cursor-arrow-rays"
  defp group_icon("Overlays"), do: "hero-squares-2x2"
  defp group_icon("Feedback"), do: "hero-speaker-wave"
  defp group_icon("Layout"), do: "hero-view-columns"
  defp group_icon("Data Display"), do: "hero-chart-bar"
  defp group_icon(_), do: "hero-document"

  defp source_code_url, do: "https://github.com/suciptoid/pui"
  defp website_url, do: "https://pui.sukacipta.com"
end
