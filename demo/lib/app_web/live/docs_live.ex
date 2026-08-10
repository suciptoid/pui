defmodule AppWeb.Live.DocsLive do
  @moduledoc """
  LiveView for rendering documentation pages with interactive component demos.

  Loads markdown documentation from NimblePublisher and renders docs content
  through MDEx so inline Phoenix demo components can live directly in markdown.
  """
  use AppWeb, :live_view
  use PUI

  require Logger

  @remote_country_options [
    {"in", "India"},
    {"us", "United States"},
    {"ca", "Canada"},
    {"au", "Australia"}
  ]

  @remote_city_options [
    {"del", "Delhi"},
    {"jak", "Jakarta"},
    {"tor", "Toronto"},
    {"syd", "Sydney"}
  ]

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
       chart_color: "var(--chart-1)",
       chart_curve: "linear",
       chart_show_area: true,
       chart_show_grid: true,
       chart_revision: 0,
       show_dialog: false,
       progress_value: 45.0,
       toast_count: 0,
       flash_position: "top-center",
       flash_stacked: true,
       ping_state: :idle,
       bg_orientation: "horizontal",
       remote_country_options: @remote_country_options,
       remote_city_options: @remote_city_options,
       remote_country_query: "",
       remote_city_query: ""
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

  def handle_event("chart_set_curve", %{"curve" => curve}, socket) do
    {:noreply, assign(socket, chart_curve: curve)}
  end

  def handle_event("chart_set_color", %{"color" => color}, socket) do
    {:noreply, assign(socket, chart_color: color)}
  end

  def handle_event("chart_toggle_area", _params, socket) do
    {:noreply, update(socket, :chart_show_area, &(!&1))}
  end

  def handle_event("chart_toggle_grid", _params, socket) do
    {:noreply, update(socket, :chart_show_grid, &(!&1))}
  end

  def handle_event("chart_advance_revision", _params, socket) do
    {:noreply, update(socket, :chart_revision, &(&1 + 1))}
  end

  def handle_event("select_bg_orientation", %{"orientation" => orientation}, socket) do
    {:noreply, assign(socket, bg_orientation: orientation)}
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

  def handle_event("send_positioned_toast", _params, socket) do
    count = socket.assigns.toast_count + 1
    PUI.Flash.send_flash("Trigger override ##{count}", position: "bottom-right")
    {:noreply, assign(socket, toast_count: count)}
  end

  def handle_event("toggle_flash_stack", _params, socket) do
    {:noreply, update(socket, :flash_stacked, &(!&1))}
  end

  def handle_event("send_preset_toast", %{"type" => type}, socket) do
    count = socket.assigns.toast_count + 1

    message =
      case type do
        "success" -> "Operation succeeded (#{count})"
        "error" -> "Something went wrong (#{count})"
        "warning" -> "Please review your input (#{count})"
        _ -> "Here is an update (#{count})"
      end

    type_atom = String.to_existing_atom(type)
    PUI.Flash.send_flash(%PUI.Flash.Message{type: type_atom, message: message})
    {:noreply, assign(socket, toast_count: count)}
  end

  def handle_event("send_custom_flash", _params, socket) do
    count = socket.assigns.toast_count + 1

    PUI.Flash.send_flash(%PUI.Flash.Message{
      type: :success,
      message: custom_flash_message(%{})
    })

    {:noreply, assign(socket, toast_count: count)}
  end

  def handle_event("dispatch_ping", _params, socket) do
    socket = assign(socket, ping_state: :connecting)

    PUI.Flash.send_flash(%PUI.Flash.Message{
      id: "ping-demo",
      message: ping_loading_message(%{}),
      duration: -1
    })

    parent = self()

    Task.start(fn ->
      Process.sleep(2000)

      result =
        case :rand.uniform(4) do
          n when n <= 3 -> :up
          _ -> :down
        end

      PUI.Flash.update_flash(parent, %PUI.Flash.Message{
        id: "ping-demo",
        message: ping_result_message(%{result: result}),
        duration: 5
      })

      send(parent, {:ping_done, result})
    end)

    {:noreply, socket}
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

  def handle_event("search_demo_countries", params, socket) do
    query = Map.get(params, "query", "")
    value = Map.get(params, "value", "")

    {:noreply,
     socket
     |> assign(
       :remote_country_options,
       remote_search_options(@remote_country_options, query, value)
     )
     |> assign(:remote_country_query, query)}
  end

  def handle_event("search_demo_cities", params, socket) do
    query = Map.get(params, "query", "")
    value = Map.get(params, "value", "")

    {:noreply,
     socket
     |> assign(:remote_city_options, remote_search_options(@remote_city_options, query, value))
     |> assign(:remote_city_query, query)}
  end

  defp ping_loading_message(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="animate-spin text-foreground size-5"
      >
        <path stroke="none" d="M0 0h24v24H0z" fill="none" />
        <path d="M12 6l0 -3" />
        <path d="M16.25 7.75l2.15 -2.15" />
        <path d="M18 12l3 0" />
        <path d="M16.25 16.25l2.15 2.15" />
        <path d="M12 18l0 3" />
        <path d="M7.75 16.25l-2.15 2.15" />
        <path d="M6 12l-3 0" />
        <path d="M7.75 7.75l-2.15 -2.15" />
      </svg>
      <div>Connecting to server...</div>
    </div>
    """
  end

  defp ping_result_message(%{result: :up} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.icon name="hero-check-circle" class="size-6 text-green-600" />
      <div>Server connected</div>
    </div>
    """
  end

  defp ping_result_message(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.icon name="hero-x-circle" class="size-6 text-red-600" />
      <div>Server unreachable</div>
    </div>
    """
  end

  defp custom_flash_message(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <.icon name="hero-check-circle" class="size-5" />
      <span>Success!</span>
    </div>
    """
  end

  @impl true
  def handle_info({:ping_done, _result}, socket) do
    {:noreply, assign(socket, ping_state: :idle)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.docs_shell
      docs={@docs}
      doc={@doc}
      flash={@flash}
      flash_position={@flash_position}
      flash_stacked={@flash_stacked}
    >
      <div :if={@doc} class="docs-enter space-y-12">
        <%!-- Page Header --%>
        <div class="relative overflow-hidden border-b border-border/70 pb-10 pt-4">
          <div class="pointer-events-none absolute -right-8 -top-20 select-none font-mono text-[11rem] font-black leading-none tracking-[-0.1em] text-foreground/[0.035] dark:text-foreground/[0.025]">
            PUI
          </div>
          <div class="relative mb-5 flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.16em] text-foreground/55">
            <span>{@doc.group}</span>
            <.icon name="hero-chevron-right-mini" class="size-3.5" />
            <span class="text-foreground font-medium">{@doc.title}</span>
          </div>
          <h1 class="relative max-w-3xl text-5xl font-black tracking-[-0.055em] text-foreground sm:text-6xl">
            {@doc.title}
          </h1>
          <p class="relative mt-5 max-w-2xl text-lg leading-8 text-foreground/70">
            {@doc.description}
          </p>
        </div>

        <article class="prose prose-zinc dark:prose-invert max-w-none prose-p:text-foreground/75 prose-li:text-foreground/75 prose-strong:text-foreground prose-headings:text-foreground prose-headings:scroll-mt-24 prose-headings:tracking-[-0.025em] prose-a:font-semibold prose-a:text-foreground prose-a:underline prose-a:decoration-foreground/25 prose-a:underline-offset-4 hover:prose-a:decoration-foreground/70 prose-pre:rounded-2xl prose-pre:border prose-pre:border-border/70 prose-pre:shadow-sm prose-code:before:content-none prose-code:after:content-none">
          {App.Docs.Doc.render(@doc.body, docs_body_assigns(assigns))}
        </article>
      </div>
    </.docs_shell>
    """
  end

  # ── Docs shell layout (PUI.Layout) ─────────────────────────────────────

  attr :docs, :list, required: true
  attr :doc, :any, default: nil
  attr :flash, :map, required: true
  attr :flash_position, :string, default: "top-right"
  attr :flash_stacked, :boolean, default: true
  slot :inner_block, required: true

  defp docs_shell(assigns) do
    ~H"""
    <PUI.Flash.flash_group
      flash={@flash}
      live={true}
      position={@flash_position}
      stacked={@flash_stacked}
    />

    <.app_layout id="docs-shell" class="pui-editorial" content_class="p-0 bg-background">
      <:sidebar>
        <%!-- Mobile overlay --%>
        <div
          id="docs-mobile-overlay"
          class="fixed inset-0 z-40 bg-black/50 hidden lg:hidden"
          phx-click={
            JS.add_class("hidden", to: "#docs-sidebar")
            |> JS.add_class("hidden", to: "#docs-mobile-overlay")
          }
        />

        <.sidebar
          id="docs-sidebar"
          class="hidden lg:flex fixed lg:relative inset-y-0 left-0 z-50 lg:z-auto"
        >
          <:header>
            <div class="flex h-20 shrink-0 items-center justify-between border-b border-border/70 px-5">
              <.link navigate={~p"/"} class="flex items-center gap-3 group">
                <div class="flex flex-col">
                  <span class="text-lg font-black tracking-[-0.04em] text-foreground">PUI</span>
                  <span class="text-[10px] font-medium uppercase tracking-[0.16em] leading-none text-foreground/45">LiveView UI</span>
                </div>
              </.link>
              <button
                type="button"
                class="lg:hidden rounded-md p-1.5 text-foreground/60 hover:bg-accent"
                phx-click={
                  JS.add_class("hidden", to: "#docs-sidebar")
                  |> JS.add_class("hidden", to: "#docs-mobile-overlay")
                }
              >
                <.icon name="hero-x-mark" class="size-5" />
              </button>
            </div>
          </:header>

          <nav class="flex flex-col gap-4 p-3 pt-5 group-data-[collapsed=true]/pui-layout:gap-0 group-data-[collapsed=true]/pui-layout:px-0 group-data-[collapsed=true]/pui-layout:py-0">
            <div :for={{group, docs} <- @docs}>
              <.sidebar_menu_item
                title={group}
                collapsible
                expanded={true}
              >
                <:icon><.icon name={group_icon(group)} /></:icon>
                <:subitem :for={d <- docs}>
                  <.link
                    patch={~p"/docs/#{d.id}"}
                    class={[
                      "group/doc-link relative block rounded-md px-2 py-1.5 text-sm transition-all duration-200",
                      @doc && @doc.id == d.id &&
                        "bg-foreground text-background font-semibold shadow-sm",
                      !(@doc && @doc.id == d.id) &&
                        "text-foreground/65 hover:bg-accent hover:text-accent-foreground"
                    ]}
                  >
                    {d.title}
                  </.link>
                </:subitem>
              </.sidebar_menu_item>
            </div>
          </nav>
        </.sidebar>
      </:sidebar>

      <:header>
        <.content_header
          shell_id="docs-shell"
          breadcrumb_parent="Docs"
          breadcrumb_current={if(@doc, do: @doc.title, else: "Documentation")}
          toggle_class="hidden lg:grid"
        >
          <:right_actions>
            <button
              type="button"
              class="lg:hidden grid h-9 w-9 shrink-0 place-items-center rounded-lg text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
              phx-click={
                JS.remove_class("hidden", to: "#docs-sidebar")
                |> JS.remove_class("hidden", to: "#docs-mobile-overlay")
              }
            >
              <.icon name="hero-bars-3" class="h-4 w-4" />
            </button>
            <.link
              navigate={~p"/demo/overview"}
              class="hidden sm:inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
            >
              <.icon name="hero-play" class="size-3.5" /> Live Demo
            </.link>
            <a
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="hidden sm:grid h-9 w-9 shrink-0 place-items-center rounded-lg text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
              title="Source code"
            >
              <.icon name="hero-code-bracket" class="h-4 w-4" />
            </a>
            <a
              href="https://hexdocs.pm/pui"
              target="_blank"
              class="hidden sm:grid h-9 w-9 shrink-0 place-items-center rounded-lg text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
              title="HexDocs"
            >
              <.icon name="hero-book-open" class="h-4 w-4" />
            </a>
            <Layouts.theme_toggle />
          </:right_actions>
        </.content_header>
      </:header>

      <div class="flex min-h-full">
        <div class="flex-1 min-w-0">
          <div class="mx-auto max-w-4xl px-5 py-10 lg:px-10 lg:py-16">
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
        </div>

        <%!-- TOC --%>
        <aside
          :if={@doc && @doc.toc != []}
          class="hidden xl:block w-60 shrink-0 self-start border-l border-border/70 bg-muted/15 sticky top-0"
        >
          <div class="sticky top-0 max-h-screen overflow-y-auto px-5 py-8">
            <h5 class="mb-3 text-xs font-semibold uppercase tracking-wider text-foreground/60">
              On this page
            </h5>
            <ul class="space-y-1.5">
              <li :for={item <- @doc.toc}>
                <a
                  href={"##{item.id}"}
                  class={[
                    "block text-sm text-foreground/55 transition-colors hover:text-foreground",
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
    </.app_layout>
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

  defp remote_search_options(options, query, selected_value) do
    normalized_query = String.downcase(String.trim(query))

    matches =
      if normalized_query == "" do
        options
      else
        Enum.filter(options, fn {_value, label} ->
          String.contains?(String.downcase(label), normalized_query)
        end)
      end

    selected_option = Enum.find(options, fn {value, _label} -> value == selected_value end)

    if selected_option && not Enum.any?(matches, fn option -> option == selected_option end) do
      [selected_option | matches]
    else
      matches
    end
  end

  defp docs_body_assigns(assigns) do
    Map.take(assigns, [
      :btn_size,
      :btn_variant,
      :active_tab,
      :chart_color,
      :chart_curve,
      :chart_show_area,
      :chart_show_grid,
      :chart_revision,
      :flash,
      :flash_position,
      :flash_stacked,
      :bg_orientation,
      :form,
      :ping_state,
      :progress_value,
      :show_dialog,
      :toast_count,
      :remote_country_options,
      :remote_city_options,
      :remote_country_query,
      :remote_city_query
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
end
