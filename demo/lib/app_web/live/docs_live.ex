defmodule AppWeb.Live.DocsLive do
  @moduledoc """
  LiveView for rendering documentation pages with interactive component demos.

  Loads markdown documentation from NimblePublisher and renders interactive
  PUI component examples alongside the prose content.
  """
  use AppWeb, :live_view
  use PUI

  @impl true
  def mount(_params, _session, socket) do
    docs = App.Docs.grouped_docs()

    {:ok,
     socket
     |> assign(docs: docs)
     |> assign(form: to_form(%{"name" => "", "email" => "", "select" => ""}))
     |> assign(
       btn_variant: "default",
       btn_size: "default",
       show_dialog: false,
       progress_value: 45.0,
       toast_count: 0
     )}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    doc = App.Docs.get_doc!(slug)

    {:noreply,
     socket
     |> assign(doc: doc, page_title: doc.title)
     |> assign(live_action: :show)}
  end

  def handle_params(_params, _uri, socket) do
    docs = App.Docs.all_docs()
    first_doc = List.first(docs)

    if first_doc do
      {:noreply, push_navigate(socket, to: ~p"/docs/#{first_doc.id}")}
    else
      {:noreply, assign(socket, doc: nil, page_title: "Documentation", live_action: :index)}
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
    <.docs_shell docs={@docs} doc={@doc} flash={@flash}>
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
  slot :inner_block, required: true

  defp docs_shell(assigns) do
    ~H"""
    <div class="flex min-h-screen bg-background">
      <PUI.Flash.flash_group flash={@flash} live={true} position="top-right" />

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
          <div class="flex items-center justify-between border-b border-border px-5 py-4">
            <a href="/" class="flex items-center gap-3 group">
              <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
                <.icon name="hero-cube" class="size-4" />
              </div>
              <div class="flex flex-col">
                <span class="text-base font-bold text-foreground">PUI</span>
                <span class="text-[10px] text-muted-foreground leading-none">Documentation</span>
              </div>
            </a>
            <button
              class="lg:hidden p-1.5 rounded-md hover:bg-accent text-muted-foreground"
              phx-click={JS.hide(to: "#docs-mobile-sidebar") |> JS.hide(to: "#docs-mobile-overlay")}
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <%!-- Navigation --%>
          <nav class="flex-1 overflow-y-auto p-4 space-y-6">
            <div :for={{group, docs} <- @docs}>
              <h3 class="flex items-center gap-2 px-3 py-2 mb-1 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
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
                        "text-muted-foreground hover:bg-accent/50 hover:text-foreground"
                    ]}
                  >
                    {d.title}
                  </.link>
                </li>
              </ul>
            </div>
          </nav>

          <%!-- Footer --%>
          <div class="border-t border-border p-4">
            <div class="flex items-center justify-between">
              <a
                href="/"
                class="text-xs text-muted-foreground hover:text-foreground transition-colors"
              >
                ← Back to Demo
              </a>
              <Layouts.theme_toggle />
            </div>
          </div>
        </div>
      </aside>

      <%!-- Main --%>
      <div class="flex flex-1 flex-col min-w-0">
        <%!-- Top bar --%>
        <header class="flex items-center justify-between border-b border-border px-4 lg:px-8 py-3 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-30">
          <div class="flex items-center gap-4">
            <button
              class="lg:hidden p-2 -ml-2 rounded-md hover:bg-accent"
              phx-click={JS.show(to: "#docs-mobile-sidebar") |> JS.show(to: "#docs-mobile-overlay")}
            >
              <.icon name="hero-bars-3" class="size-5" />
            </button>
            <span class="text-sm font-medium text-foreground">Documentation</span>
          </div>
          <div class="flex items-center gap-2">
            <a
              href="https://hexdocs.pm/pui"
              target="_blank"
              class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground rounded-md hover:bg-accent transition-colors"
            >
              <.icon name="hero-book-open" class="size-4" /> HexDocs
            </a>
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
                  <a href="/" class="hover:text-foreground transition-colors">
                    View Demo →
                  </a>
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
              <h5 class="mb-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                On this page
              </h5>
              <ul class="space-y-1.5">
                <li :for={item <- @doc.toc}>
                  <a
                    href={"##{item.id}"}
                    class={[
                      "block text-sm text-muted-foreground hover:text-foreground transition-colors",
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
        </div>
      </.demo_section>

      <.demo_section title="Checkbox" id="checkbox">
        <div class="space-y-3">
          <.checkbox id="demo-terms" name="terms" label="I agree to the terms and conditions" />
          <.checkbox id="demo-newsletter" name="newsletter" label="Subscribe to newsletter" />
        </div>
      </.demo_section>

      <.demo_section title="Switch" id="switch">
        <div class="space-y-3">
          <.switch id="demo-notifications" name="notifications" label="Enable notifications" />
          <.switch id="demo-darkmode" name="dark_mode" label="Dark mode" />
        </div>
      </.demo_section>

      <.demo_section title="Textarea" id="textarea">
        <div class="max-w-sm">
          <.textarea
            id="demo-bio"
            name="bio"
            label="Biography"
            placeholder="Tell us about yourself..."
            rows="4"
          />
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
          <:trigger>
            <.button variant="outline">Show Popover</.button>
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

      <.demo_section title="Tooltips" id="tooltips">
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
        <div class="flex flex-wrap gap-3">
          <.button phx-click="send_toast">
            <.icon name="hero-bell" class="size-4 mr-2" /> Send Toast
          </.button>
          <p class="text-sm text-muted-foreground self-center">
            Click to send a toast notification. Count: {@assigns.toast_count}
          </p>
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
end
