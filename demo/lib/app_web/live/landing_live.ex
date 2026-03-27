defmodule AppWeb.Live.LandingLive do
  use AppWeb, :live_view
  use PUI

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Phoenix LiveView UI Toolkit")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-background text-foreground">
      <div class="relative isolate overflow-hidden">
        <div class="absolute inset-x-0 top-0 -z-10 h-[32rem] bg-gradient-to-b from-primary/10 via-background to-background" />
        <div class="absolute left-[8%] top-20 -z-10 h-64 w-64 rounded-full bg-primary/10 blur-3xl" />
        <div class="absolute right-[8%] top-12 -z-10 h-72 w-72 rounded-full bg-sky-500/10 blur-3xl" />

        <header class="mx-auto flex max-w-7xl items-center justify-between px-6 py-6 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-3">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl border border-border/70 bg-card shadow-sm">
              <img src={~p"/images/pui-hook-2d.png"} alt="PUI" class="h-8 w-8" />
            </div>
            <div class="flex flex-col">
              <span class="text-[0.68rem] font-semibold uppercase tracking-[0.24em] text-foreground/55">
                PUI
              </span>
              <span class="text-sm font-semibold sm:text-base">Phoenix LiveView UI Toolkit</span>
            </div>
          </.link>

          <div class="flex items-center gap-3">
            <nav class="hidden items-center gap-2 md:flex">
              <.link
                navigate={~p"/docs"}
                class="inline-flex items-center gap-2 rounded-full border border-border bg-background/80 px-3 py-2 text-sm text-foreground/70 shadow-sm transition-colors hover:text-foreground"
              >
                <.icon name="hero-book-open" class="size-4" /> Docs
              </.link>
              <a
                href={website_url()}
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2 rounded-full border border-border bg-background/80 px-3 py-2 text-sm text-foreground/70 shadow-sm transition-colors hover:text-foreground"
              >
                <.icon name="hero-globe-alt" class="size-4" /> Live Site
              </a>
              <a
                href={source_code_url()}
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center gap-2 rounded-full border border-border bg-background/80 px-3 py-2 text-sm text-foreground/70 shadow-sm transition-colors hover:text-foreground"
              >
                <.icon name="hero-code-bracket" class="size-4" /> Source Code
              </a>
            </nav>

            <Layouts.theme_toggle />
          </div>
        </header>

        <main class="mx-auto max-w-7xl px-6 pb-20 pt-6 lg:px-8 lg:pb-24 lg:pt-10">
          <section class="grid gap-12 lg:grid-cols-[minmax(0,1fr)_24rem] lg:items-center">
            <div class="max-w-3xl">
              <div class="inline-flex items-center gap-2 rounded-full border border-border bg-background/85 px-3 py-1 text-sm text-foreground/70 shadow-sm backdrop-blur">
                <.icon name="hero-sparkles" class="size-4 text-primary" />
                Beautiful LiveView components without the busywork
              </div>

              <h1 class="mt-6 text-5xl font-semibold tracking-tight sm:text-6xl">
                Build polished Phoenix LiveView interfaces with a calm, minimal system.
              </h1>

              <p class="mt-6 max-w-2xl text-lg leading-8 text-foreground/70">
                PUI gives you accessible, theme-ready components that feel at home in LiveView
                applications, so you can ship consistent product UI faster.
              </p>

              <div class="mt-8 flex flex-wrap items-center gap-3">
                <.button navigate={~p"/docs"} size="lg" class="shadow-sm">
                  <.icon name="hero-book-open" class="size-4" /> Read the docs
                </.button>

                <.button
                  variant="outline"
                  size="lg"
                  href={source_code_url()}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <.icon name="hero-code-bracket" class="size-4" /> Source code
                </.button>
              </div>

              <div class="mt-6 flex flex-wrap gap-3">
                <span
                  :for={tag <- hero_tags()}
                  class="inline-flex items-center rounded-full bg-muted px-3 py-1 text-sm text-foreground/65"
                >
                  {tag}
                </span>
              </div>
            </div>

            <div class="rounded-[2rem] border border-border/80 bg-card/80 p-6 shadow-xl shadow-black/5 backdrop-blur">
              <div class="flex items-start justify-between gap-4">
                <div>
                  <p class="text-sm font-semibold">A cleaner starting point</p>
                  <p class="mt-1 text-sm text-foreground/65">
                    Keep the homepage focused while interactive demos live in the docs.
                  </p>
                </div>

                <span class="inline-flex rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
                  Quickstart
                </span>
              </div>

              <div class="mt-6 space-y-4">
                <div class="rounded-2xl border border-border bg-background/90 p-4">
                  <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    Install
                  </p>
                  <pre class="mt-3 overflow-x-auto text-sm font-medium text-foreground/80"><code>mix deps.get</code></pre>
                </div>

                <div class="rounded-2xl border border-border bg-background/90 p-4">
                  <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    Import
                  </p>
                  <pre class="mt-3 overflow-x-auto text-sm font-medium text-foreground/80"><code>use PUI</code></pre>
                </div>

                <div class="grid gap-4 sm:grid-cols-2">
                  <.resource_card
                    title="Component docs"
                    description="Browse usage guides, examples, and APIs."
                    icon="hero-book-open"
                    href={~p"/docs"}
                  />
                  <.resource_card
                    title="Live site"
                    description="See the public landing experience."
                    icon="hero-globe-alt"
                    href={website_url()}
                    target="_blank"
                  />
                </div>
              </div>
            </div>
          </section>
        </main>
      </div>

      <section class="mx-auto max-w-7xl px-6 pb-8 lg:px-8">
        <div class="rounded-[2rem] border border-border/80 bg-card/70 p-6 shadow-sm sm:p-8 lg:p-10">
          <div class="grid gap-8 lg:grid-cols-[minmax(0,0.95fr)_minmax(0,1.05fr)] lg:items-start">
            <div>
              <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Quickstart</p>
              <h2 class="mt-4 text-3xl font-semibold tracking-tight">
                Go from install to first component in a few focused steps.
              </h2>
              <p class="mt-4 max-w-2xl text-base leading-7 text-foreground/70">
                The landing page stays lightweight, while `/docs` holds the full component demos and
                API details. Use this section to get set up quickly and move straight into the docs.
              </p>

              <div class="mt-8 grid gap-4 md:grid-cols-3 lg:grid-cols-1 xl:grid-cols-3">
                <div
                  :for={step <- quickstart_steps()}
                  class="rounded-2xl border border-border bg-background/90 p-5"
                >
                  <div class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    {step.step}
                  </div>
                  <h3 class="mt-3 text-base font-semibold">{step.title}</h3>
                  <p class="mt-2 text-sm leading-6 text-foreground/65">{step.description}</p>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <div class="rounded-3xl border border-border bg-background p-5">
                <div class="flex items-center justify-between gap-3">
                  <p class="text-sm font-semibold">1. Add PUI to your project</p>
                  <span class="text-xs text-foreground/50">mix.exs</span>
                </div>
                <div class="mt-4">
                  <.code_block code={dependency_code()} language="elixir" />
                </div>
              </div>

              <div class="rounded-3xl border border-border bg-background p-5">
                <div class="flex items-center justify-between gap-3">
                  <p class="text-sm font-semibold">2. Start using components</p>
                  <span class="text-xs text-foreground/50">LiveView</span>
                </div>
                <div class="mt-4">
                  <.code_block code={usage_code()} language="elixir" />
                </div>
              </div>

              <div class="rounded-3xl border border-border bg-background p-5">
                <div class="flex items-start gap-3">
                  <div class="mt-0.5 rounded-xl bg-primary/10 p-2 text-primary">
                    <.icon name="hero-squares-2x2" class="size-4" />
                  </div>
                  <div>
                    <p class="text-sm font-semibold">Need the full setup?</p>
                    <p class="mt-2 text-sm leading-6 text-foreground/65">
                      Head to
                      <.link navigate={~p"/docs"} class="text-primary hover:text-primary/80">
                        /docs
                      </.link>
                      for component examples, usage patterns, and the complete integration guide.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="mx-auto max-w-7xl px-6 pb-24 lg:px-8">
        <div class="max-w-2xl">
          <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Features</p>
          <h2 class="mt-4 text-3xl font-semibold tracking-tight">
            A docs-first, production-minded toolkit with minimal surface area.
          </h2>
          <p class="mt-4 text-base leading-7 text-foreground/70">
            These bento cards highlight the pieces of PUI that help teams move quickly without
            overcomplicating the interface layer.
          </p>
        </div>

        <div class="mt-10 grid gap-4 md:grid-cols-3">
          <div class="rounded-[2rem] border border-border bg-card p-6 shadow-sm md:col-span-2">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name="hero-bolt" class="size-5" />
            </div>

            <div class="mt-6 grid gap-6 lg:grid-cols-[minmax(0,1fr)_17rem]">
              <div>
                <p class="text-sm font-semibold text-foreground/70">Built for LiveView</p>
                <h3 class="mt-2 text-2xl font-semibold tracking-tight">
                  Phoenix-native components with sane defaults.
                </h3>
                <p class="mt-4 text-sm leading-7 text-foreground/65">
                  Use composable UI primitives that feel natural in LiveViews and function
                  components, with minimal client-side complexity and a clean visual baseline.
                </p>
              </div>

              <ul class="space-y-3 rounded-2xl border border-border bg-background/80 p-4 text-sm text-foreground/70">
                <li :for={item <- liveview_points()} class="flex gap-3">
                  <span class="mt-1 h-2 w-2 shrink-0 rounded-full bg-primary" />
                  <span>{item}</span>
                </li>
              </ul>
            </div>
          </div>

          <div class="rounded-[2rem] border border-border bg-card p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name="hero-shield-check" class="size-5" />
            </div>
            <h3 class="mt-6 text-xl font-semibold tracking-tight">Accessible interactions</h3>
            <p class="mt-3 text-sm leading-7 text-foreground/65">
              Build with components that already account for states, focus behavior, and interaction
              patterns you do not want to reinvent.
            </p>
          </div>

          <div class="rounded-[2rem] border border-border bg-card p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name="hero-swatch" class="size-5" />
            </div>
            <h3 class="mt-6 text-xl font-semibold tracking-tight">Theme-ready defaults</h3>
            <p class="mt-3 text-sm leading-7 text-foreground/65">
              Start with polished defaults, then adapt the styling to your system without fighting
              heavy abstractions.
            </p>
          </div>

          <div class="rounded-[2rem] border border-border bg-card p-6 shadow-sm">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name="hero-squares-2x2" class="size-5" />
            </div>
            <h3 class="mt-6 text-xl font-semibold tracking-tight">Composable building blocks</h3>
            <p class="mt-3 text-sm leading-7 text-foreground/65">
              Reach for buttons, inputs, overlays, menus, tabs, and layout helpers with consistent
              APIs across the toolkit.
            </p>
          </div>

          <div class="rounded-[2rem] border border-border bg-card p-6 shadow-sm md:col-span-2">
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name="hero-arrow-top-right-on-square" class="size-5" />
            </div>

            <div class="mt-6 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
              <div class="max-w-xl">
                <p class="text-sm font-semibold text-foreground/70">Resources</p>
                <h3 class="mt-2 text-2xl font-semibold tracking-tight">
                  Jump into the docs, review the source, or open the live site.
                </h3>
                <p class="mt-4 text-sm leading-7 text-foreground/65">
                  Everything you need to evaluate, integrate, and explore PUI is one click away.
                </p>
              </div>

              <div class="flex flex-wrap gap-3">
                <.button navigate={~p"/docs"} variant="outline">
                  <.icon name="hero-book-open" class="size-4" /> Docs
                </.button>
                <.button
                  href={source_code_url()}
                  variant="outline"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <.icon name="hero-code-bracket" class="size-4" /> Source code
                </.button>
                <.button
                  href={website_url()}
                  variant="outline"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <.icon name="hero-globe-alt" class="size-4" /> Live site
                </.button>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :href, :string, required: true
  attr :target, :string, default: nil

  defp resource_card(assigns) do
    ~H"""
    <a
      href={@href}
      target={@target}
      rel={if @target == "_blank", do: "noopener noreferrer", else: nil}
      class="group rounded-2xl border border-border bg-background/90 p-4 transition-colors hover:border-primary/40 hover:bg-background"
    >
      <div class="flex items-start justify-between gap-3">
        <div>
          <p class="text-sm font-semibold">{@title}</p>
          <p class="mt-2 text-sm leading-6 text-foreground/65">{@description}</p>
        </div>

        <div class="rounded-xl bg-primary/10 p-2 text-primary transition-colors group-hover:bg-primary/15">
          <.icon name={@icon} class="size-4" />
        </div>
      </div>
    </a>
    """
  end

  defp hero_tags do
    ["LiveView-native", "Accessible by default", "Theme-ready"]
  end

  defp quickstart_steps do
    [
      %{
        step: "Step 01",
        title: "Install the dependency",
        description: "Add `pui` to your project and fetch dependencies with `mix deps.get`."
      },
      %{
        step: "Step 02",
        title: "Import the toolkit",
        description:
          "Use `PUI` inside your LiveViews so the components are available where you build UI."
      },
      %{
        step: "Step 03",
        title: "Use the docs",
        description: "Open `/docs` for component demos, usage notes, and implementation details."
      }
    ]
  end

  defp liveview_points do
    [
      "Form-friendly APIs and LiveView integration",
      "Consistent primitives for inputs, actions, overlays, and layout",
      "Minimal styling surface with room for customization"
    ]
  end

  defp dependency_code do
    """
    defp deps do
      [
        {:pui, "~> 1.0.0-alpha"}
      ]
    end
    """
  end

  defp usage_code do
    """
    defmodule MyAppWeb.SettingsLive do
      use MyAppWeb, :live_view
      use PUI

      def render(assigns) do
        ~H\"\"\"
        <div class="space-y-4">
          <.button>Save changes</.button>
          <.input name="email" label="Email" />
        </div>
        \"\"\"
      end
    end
    """
  end

  defp source_code_url, do: "https://github.com/suciptoid/pui"
  defp website_url, do: "https://pui.sukacipta.com"
end
