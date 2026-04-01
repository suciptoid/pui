defmodule AppWeb.Live.DocsLive do
  @moduledoc """
  LiveView for rendering documentation pages with interactive component demos.

  Loads markdown documentation from NimblePublisher and renders docs content
  through MDEx so inline Phoenix demo components can live directly in markdown.
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
     |> assign(
       form:
         build_docs_form(%{
           "name" => "",
           "email" => "",
           "notes" => "",
           "select" => "",
           "terms" => "false",
           "notifications" => "false",
           "plan" => ""
         })
     )
     |> assign(page_title: seo.title, seo: seo)
     |> assign(
       btn_variant: "default",
       btn_size: "default",
       active_tab: "overview",
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

  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
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
    {:noreply, assign(socket, form: build_docs_form(params["demo"] || %{}, validate?: true))}
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

        <article class="prose prose-zinc dark:prose-invert max-w-none prose-headings:scroll-mt-24 prose-a:text-primary hover:prose-a:text-primary/80 prose-pre:rounded-xl prose-pre:border prose-pre:border-border prose-code:before:content-none prose-code:after:content-none">
          {App.Docs.Doc.render(@doc.body, docs_body_assigns(assigns))}
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

  defp build_docs_form(params, opts \\ []) do
    errors =
      []
      |> maybe_error(:name, blank?(params["name"]), "Please enter your full name.")
      |> maybe_error(
        :email,
        invalid_email?(params["email"]),
        "Please enter a valid email address."
      )
      |> maybe_error(:notes, blank?(params["notes"]), "Please add a short note.")
      |> maybe_error(:select, blank?(params["select"]), "Please choose an option.")

    form_opts =
      [as: :demo]
      |> maybe_put_option(:errors, errors, errors != [])
      |> maybe_put_option(:action, :validate, Keyword.get(opts, :validate?, false))

    to_form(params, form_opts)
  end

  defp maybe_error(errors, field, true, message), do: [{field, {message, []}} | errors]
  defp maybe_error(errors, _field, false, _message), do: errors

  defp maybe_put_option(opts, key, value, true), do: Keyword.put(opts, key, value)
  defp maybe_put_option(opts, _key, _value, false), do: opts

  defp blank?(value), do: value in [nil, ""]
  defp invalid_email?(value), do: blank?(value) or not String.contains?(value, "@")

  defp docs_body_assigns(assigns) do
    Map.take(assigns, [
      :btn_size,
      :btn_variant,
      :active_tab,
      :flash,
      :flash_position,
      :form,
      :progress_value,
      :show_dialog,
      :toast_count
    ])
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
