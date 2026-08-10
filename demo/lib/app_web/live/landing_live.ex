defmodule AppWeb.Live.LandingLive do
  @moduledoc "Landing page for the PUI Phoenix LiveView component library."
  use AppWeb, :live_view
  use PUI

  @impl true
  def mount(_params, _session, socket) do
    seo = AppWeb.Seo.landing_meta()
    {:ok, assign(socket, page_title: seo.title, seo: seo)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="landing-page min-h-screen overflow-hidden bg-background text-foreground">
      <header class="landing-enter relative z-20 mx-auto flex h-20 max-w-[90rem] items-center justify-between border-b border-border/70 px-5 sm:px-8 lg:px-12">
        <.link navigate={~p"/"} class="text-2xl font-black tracking-[-0.06em]">PUI</.link>

        <nav class="flex items-center gap-1 sm:gap-2" aria-label="Primary navigation">
          <.link
            navigate={~p"/demo/overview"}
            class="hidden px-3 py-2 text-sm font-medium text-foreground/60 transition-colors hover:text-foreground sm:block"
          >
            Demo
          </.link>
          <.button navigate={~p"/docs"} variant="outline" size="sm">Documentation</.button>
          <Layouts.theme_toggle />
        </nav>
      </header>

      <main>
        <section class="relative mx-auto grid min-h-[calc(100svh-5rem)] max-w-[90rem] content-between overflow-hidden px-5 py-10 sm:px-8 sm:py-14 lg:px-12 lg:py-16">
          <div class="landing-grid pointer-events-none absolute inset-0 opacity-60" />
          <div class="landing-orbit pointer-events-none absolute -right-24 top-12 size-[32rem] rounded-full border border-foreground/10 sm:size-[44rem]" />

          <div class="landing-enter-delay relative z-10 flex items-center justify-between">
            <p class="text-xs font-bold uppercase tracking-[0.22em] text-foreground/55">
              Phoenix LiveView UI toolkit
            </p>
            <p class="font-mono text-xs text-foreground/45">v1.0.0</p>
          </div>

          <div class="landing-enter-delay-2 relative z-10 my-16 max-w-6xl">
            <p class="mb-5 text-sm font-semibold text-foreground/60">
              Components that belong in your codebase.
            </p>
            <h1 class="max-w-6xl text-[clamp(3rem,8vw,7rem)] font-black leading-[0.98] tracking-[-0.025em] text-foreground">
              <span class="block">Ship LiveView</span>
              <span class="block">that feels alive.</span>
            </h1>
            <div class="mt-9 flex flex-col gap-6 sm:flex-row sm:items-center">
              <.button navigate={~p"/docs"} size="lg">Start building</.button>
              <a
                href={source_code_url()}
                target="_blank"
                rel="noopener noreferrer"
                class="group inline-flex w-fit items-center gap-3 text-sm font-semibold text-foreground"
              >
                View source
                <span class="transition-transform duration-200 group-hover:translate-x-1">→</span>
              </a>
            </div>
          </div>

          <div class="landing-enter-delay-3 relative z-10 grid gap-5 border-t border-border/70 pt-5 text-sm text-foreground/60 sm:grid-cols-3">
            <p>Accessible primitives</p>
            <p>Server and browser state</p>
            <p class="sm:text-right">Theme-ready by default</p>
          </div>
        </section>

        <section class="border-y border-border/70 bg-muted/15 px-5 py-16 sm:px-8 lg:px-12 lg:py-24">
          <div class="mx-auto max-w-[84rem]">
            <div class="mb-10 grid gap-6 lg:grid-cols-2 lg:items-end">
              <div>
                <p class="text-xs font-bold uppercase tracking-[0.22em] text-foreground/50">
                  A real working surface
                </p>
                <h2 class="mt-4 max-w-xl text-4xl font-black tracking-[-0.055em] sm:text-6xl">
                  Not a screenshot.<br />A live composition.
                </h2>
              </div>
              <p class="max-w-xl text-base leading-7 text-foreground/65 lg:justify-self-end">
                Charts, navigation, menus, tabs, forms, and feedback share one deliberate system while remaining ordinary Phoenix components.
              </p>
            </div>

            <div class="landing-workspace overflow-hidden border border-border bg-background shadow-2xl shadow-foreground/5">
              <div class="flex h-14 items-center justify-between border-b border-border/70 px-5">
                <div>
                  <p class="text-sm font-bold tracking-tight">Release workspace</p>
                  <p class="text-xs text-foreground/45">Live component composition</p>
                </div>
                <div class="flex gap-2">
                  <.button variant="outline" size="sm">Share</.button>
                  <.button size="sm">New release</.button>
                </div>
              </div>

              <div class="grid min-h-[34rem] lg:grid-cols-[12rem_1fr]">
                <nav
                  class="hidden border-r border-border/70 p-4 lg:block"
                  aria-label="Workspace navigation"
                >
                  <p class="mb-4 px-2 text-[10px] font-bold uppercase tracking-[0.18em] text-foreground/40">
                    Workspace
                  </p>
                  <div class="space-y-1">
                    <p class="rounded-md bg-foreground px-3 py-2 text-sm font-semibold text-background">
                      Overview
                    </p>
                    <p class="px-3 py-2 text-sm text-foreground/50">Activity</p>
                    <p class="px-3 py-2 text-sm text-foreground/50">Components</p>
                    <p class="px-3 py-2 text-sm text-foreground/50">Settings</p>
                  </div>
                </nav>

                <div class="min-w-0 p-5 sm:p-8">
                  <div class="grid gap-5 border-b border-border/70 pb-8 sm:grid-cols-3">
                    <div :for={metric <- metrics()} class="border-t border-border pt-4">
                      <p class="text-xs font-medium text-foreground/50">{metric.label}</p>
                      <p class="mt-2 text-3xl font-black tracking-[-0.055em]">{metric.value}</p>
                      <p class="mt-1 text-xs text-foreground/45">{metric.change}</p>
                    </div>
                  </div>

                  <div class="grid gap-8 pt-8 xl:grid-cols-[1.35fr_0.65fr]">
                    <div>
                      <div class="mb-5 flex items-center justify-between">
                        <div>
                          <p class="text-sm font-semibold">Delivery trend</p>
                          <p class="text-xs text-foreground/45">Last six releases</p>
                        </div>
                        <.badge variant="secondary">Live</.badge>
                      </div>
                      <.line_chart
                        id="landing-delivery-chart"
                        card={false}
                        area={true}
                        height={230}
                        labels={["R.14", "R.15", "R.16", "R.17", "R.18", "R.19"]}
                        series={[%{label: "Changes", data: [24, 31, 29, 46, 52, 64]}]}
                      />
                    </div>

                    <div class="border-t border-border/70 pt-5 xl:border-l xl:border-t-0 xl:pl-7 xl:pt-0">
                      <p class="text-sm font-semibold">Release checklist</p>
                      <div class="mt-5 divide-y divide-border/70">
                        <div
                          :for={item <- checklist()}
                          class="flex items-center justify-between py-3 text-sm"
                        >
                          <span class="text-foreground/65">{item}</span>
                          <span class="font-mono text-xs text-foreground/35">Ready</span>
                        </div>
                      </div>
                      <.button navigate={~p"/demo/overview"} variant="outline" class="mt-6 w-full">
                        Explore the live demo
                      </.button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="mx-auto max-w-[84rem] px-5 py-20 sm:px-8 lg:px-12 lg:py-32">
          <div class="grid gap-12 lg:grid-cols-[0.75fr_1.25fr]">
            <div class="lg:sticky lg:top-10 lg:self-start">
              <p class="text-xs font-bold uppercase tracking-[0.22em] text-foreground/50">
                The system
              </p>
              <h2 class="mt-4 text-4xl font-black tracking-[-0.055em] sm:text-5xl">
                Less glue.<br />More product.
              </h2>
            </div>
            <div class="divide-y divide-border/70 border-y border-border/70">
              <div
                :for={{number, title, description} <- capabilities()}
                class="group grid gap-4 py-8 sm:grid-cols-[3rem_12rem_1fr] sm:py-10"
              >
                <span class="font-mono text-xs text-foreground/35">{number}</span>
                <h3 class="text-lg font-bold tracking-tight">{title}</h3>
                <p class="max-w-xl text-sm leading-7 text-foreground/60 transition-colors group-hover:text-foreground/75">
                  {description}
                </p>
              </div>
            </div>
          </div>
        </section>

        <section class="border-y border-border/70 bg-foreground px-5 py-20 text-background sm:px-8 lg:px-12 lg:py-28">
          <div class="mx-auto grid max-w-[84rem] gap-14 lg:grid-cols-[0.85fr_1.15fr] lg:items-start">
            <div>
              <p class="text-xs font-bold uppercase tracking-[0.22em] text-background/45">
                From dependency to interface
              </p>
              <h2 class="mt-5 max-w-xl text-4xl font-black leading-[0.95] tracking-[-0.055em] sm:text-6xl">
                Add PUI.<br />Keep building.
              </h2>
              <p class="mt-6 max-w-md text-base leading-7 text-background/60">
                The library joins the conventions you already use—Mix dependencies, function components, HEEx, and focused JavaScript hooks.
              </p>
            </div>

            <div class="border-y border-background/15">
              <div
                :for={{number, title, detail} <- workflow_steps()}
                class="grid gap-4 border-b border-background/15 py-7 last:border-b-0 sm:grid-cols-[3rem_11rem_1fr]"
              >
                <span class="font-mono text-xs text-background/35">{number}</span>
                <h3 class="font-bold tracking-tight">{title}</h3>
                <p class="text-sm leading-6 text-background/55">{detail}</p>
              </div>

              <div class="flex items-center justify-between gap-4 border-t border-background/15 py-5">
                <code class="min-w-0 overflow-x-auto font-mono text-sm text-background/80">
                  {installation_snippet()}
                </code>
                <button
                  id="copy-landing-install"
                  type="button"
                  phx-hook="CopyCode"
                  data-code={installation_snippet()}
                  class="shrink-0 border border-background/20 px-3 py-2 text-xs font-semibold text-background transition-colors hover:bg-background hover:text-foreground"
                >
                  Copy
                </button>
              </div>
            </div>
          </div>
        </section>

        <section class="mx-auto max-w-[84rem] px-5 py-20 sm:px-8 lg:px-12 lg:py-28">
          <div class="grid gap-12 lg:grid-cols-[0.65fr_1.35fr]">
            <div>
              <p class="text-xs font-bold uppercase tracking-[0.22em] text-foreground/50">
                Component catalog
              </p>
              <h2 class="mt-5 text-4xl font-black leading-[0.96] tracking-[-0.055em] sm:text-5xl">
                Small primitives.<br />Complete surfaces.
              </h2>
              <.link
                navigate={~p"/docs"}
                class="group mt-7 inline-flex items-center gap-3 text-sm font-semibold"
              >
                Browse all documentation
                <span class="transition-transform duration-200 group-hover:translate-x-1">→</span>
              </.link>
            </div>

            <div class="grid border-l border-t border-border/70 sm:grid-cols-2">
              <div
                :for={group <- component_groups()}
                class="group border-b border-r border-border/70 p-6 transition-colors hover:bg-muted/40 sm:p-8"
              >
                <div class="flex items-baseline justify-between gap-4">
                  <h3 class="text-lg font-bold tracking-tight">{group.title}</h3>
                  <span class="font-mono text-xs text-foreground/35">{group.count}</span>
                </div>
                <div class="mt-6 flex flex-wrap gap-x-4 gap-y-2">
                  <.link
                    :for={component <- group.components}
                    navigate={~p"/docs/#{component.slug}"}
                    class="text-sm text-foreground/55 underline decoration-transparent underline-offset-4 transition-colors hover:text-foreground hover:decoration-foreground/30"
                  >
                    {component.label}
                  </.link>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="border-t border-border/70 px-5 py-20 sm:px-8 lg:px-12 lg:py-28">
          <div class="mx-auto flex max-w-[84rem] flex-col gap-10 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <p class="text-xs font-bold uppercase tracking-[0.22em] text-foreground/50">
                Start with PUI
              </p>
              <h2 class="mt-5 max-w-4xl text-5xl font-black leading-[0.92] tracking-[-0.07em] sm:text-7xl">
                Your next interface<br />starts in LiveView.
              </h2>
            </div>
            <.button navigate={~p"/docs"} size="lg">Read the documentation</.button>
          </div>
        </section>
      </main>

      <footer class="border-t border-border/70 px-5 py-8 sm:px-8 lg:px-12">
        <div class="mx-auto flex max-w-[84rem] items-center justify-between text-sm text-foreground/45">
          <p>© 2026 PUI</p>
          <a
            href={source_code_url()}
            target="_blank"
            rel="noopener noreferrer"
            class="transition-colors hover:text-foreground"
          >GitHub</a>
        </div>
      </footer>
    </div>
    """
  end

  defp metrics do
    [
      %{label: "Components", value: "36", change: "Production primitives"},
      %{label: "Dependencies", value: "01", change: "Phoenix LiveView"},
      %{label: "Theme modes", value: "03", change: "Light, dark, system"}
    ]
  end

  defp checklist, do: ["Keyboard paths", "Responsive shell", "Theme contrast", "Hook lifecycle"]

  defp capabilities do
    [
      {"01", "LiveView native",
       "Function components and focused hooks fit the framework instead of hiding it behind a frontend abstraction."},
      {"02", "Accessible",
       "Keyboard navigation, focus behavior, and semantic attributes are part of the component contract."},
      {"03", "Themeable",
       "Semantic CSS variables keep application identity separate from component behavior."},
      {"04", "Composable",
       "Use styled components, primitives, or the full application shell at the level each screen needs."}
    ]
  end

  defp workflow_steps do
    [
      {"01", "Install",
       "Add the package and let Mix resolve the library alongside Phoenix LiveView."},
      {"02", "Import", "Use PUI once to bring the component catalog into your web modules."},
      {"03", "Compose",
       "Build ordinary HEEx with styled components, primitives, and application layouts."}
    ]
  end

  defp installation_snippet, do: ~s({:pui, "~> 1.0"})

  defp component_groups do
    [
      %{
        title: "Actions",
        count: "06",
        components:
          components([
            {"Button", "button"},
            {"Dropdown", "dropdown"},
            {"Popover", "popover"},
            {"Dialog", "dialog"}
          ])
      },
      %{
        title: "Forms",
        count: "08",
        components:
          components([
            {"Input", "input"},
            {"Select", "select"},
            {"Checkbox", "checkbox"},
            {"Date picker", "date-picker"}
          ])
      },
      %{
        title: "Data display",
        count: "09",
        components:
          components([
            {"Table", "table"},
            {"Chart", "chart"},
            {"Badge", "badge"},
            {"Avatar", "avatar"}
          ])
      },
      %{
        title: "Structure",
        count: "07",
        components:
          components([
            {"Layout", "layout"},
            {"Tabs", "tabs"},
            {"Accordion", "accordion"},
            {"Container", "container"}
          ])
      }
    ]
  end

  defp components(items) do
    Enum.map(items, fn {label, slug} -> %{label: label, slug: slug} end)
  end

  defp source_code_url, do: "https://github.com/suciptoid/pui"
end
