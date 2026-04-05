defmodule AppWeb.Live.LandingLive do
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
          <section class="max-w-4xl">
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
          </section>
        </main>
      </div>

      <section class="mx-auto max-w-7xl px-6 pb-12 lg:px-8">
        <div class="rounded-[2rem] border border-border/80 bg-card/70 p-6 shadow-sm sm:p-8 lg:p-10">
          <div class="max-w-3xl">
            <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Quickstart</p>
            <h2 class="mt-4 text-3xl font-semibold tracking-tight">
              From install to first component, one step at a time.
            </h2>
            <p class="mt-4 text-base leading-7 text-foreground/70">
              Keep the homepage focused, and move into `/docs` when you want the full interactive
              examples and component reference.
            </p>
          </div>

          <div class="mt-8 space-y-4">
            <div class="rounded-3xl bg-background/90 p-6">
              <div class="flex flex-col gap-6 lg:grid lg:grid-cols-2 lg:items-start">
                <div>
                  <div class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    Step 01
                  </div>
                  <h3 class="mt-3 text-xl font-semibold tracking-tight">Install the dependency</h3>
                  <p class="mt-3 text-sm leading-6 text-foreground/65">
                    Add `pui` to `mix.exs`, fetch dependencies, and keep the setup small.
                  </p>
                </div>

                <div class="w-full space-y-4">
                  <.code_panel title="mix.exs">
                    <span class="block">
                      <span class="text-violet-300">defp</span> <span class="text-sky-300">deps</span>
                      <span class="text-fuchsia-300">do</span>
                    </span>
                    <span class="block pl-4 text-zinc-100">[</span>
                    <span class="block pl-8 text-zinc-100">
                      &#123;<span class="text-sky-300">:pui</span>, <span class="text-emerald-300">"~&gt; 1.0.0-alpha"</span>&#125;
                    </span>
                    <span class="block pl-4 text-zinc-100">]</span>
                    <span class="block"><span class="text-fuchsia-300">end</span></span>
                  </.code_panel>

                  <div class="rounded-2xl border border-zinc-800 bg-zinc-950/95 px-4 py-3 font-mono text-sm text-zinc-100 shadow-sm">
                    <span class="text-zinc-500">$</span> mix deps.get
                  </div>
                </div>
              </div>
            </div>

            <div class="rounded-3xl bg-background/90 p-6 ">
              <div class="flex flex-col gap-6 lg:grid lg:grid-cols-2 lg:items-start">
                <div>
                  <div class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    Step 02
                  </div>
                  <h3 class="mt-3 text-xl font-semibold tracking-tight">Import and use PUI</h3>
                  <p class="mt-3 text-sm leading-6 text-foreground/65">
                    Bring the toolkit into your LiveView and start composing UI with the provided
                    components.
                  </p>
                </div>

                <div class="w-full">
                  <.code_panel title="settings_live.ex">
                    <span class="block">
                      <span class="text-violet-300">defmodule</span>
                      <span class="text-sky-300">MyAppWeb.SettingsLive</span>
                      <span class="text-fuchsia-300">do</span>
                    </span>
                    <span class="block pl-4">
                      <span class="text-violet-300">use</span>
                      <span class="text-zinc-100">MyAppWeb</span>,
                      <span class="text-amber-300">:live_view</span>
                    </span>
                    <span class="block pl-4">
                      <span class="text-violet-300">use</span> <span class="text-zinc-100">PUI</span>
                    </span>
                    <span class="block pl-4 mt-2">
                      <span class="text-violet-300">def</span>
                      <span class="text-sky-300">render</span>(<span class="text-zinc-100">assigns</span>)
                      <span class="text-fuchsia-300">do</span>
                    </span>
                    <span class="block pl-8">
                      <span class="text-amber-300">~H&quot;&quot;&quot;</span>
                    </span>
                    <span class="block pl-8">
                      <span class="text-cyan-300">&lt;div class="space-y-4"&gt;</span>
                    </span>
                    <span class="block pl-12">
                      <span class="text-cyan-300">&lt;.button&gt;</span><span class="text-zinc-100">Save changes</span><span class="text-cyan-300">&lt;/.button&gt;</span>
                    </span>
                    <span class="block pl-12">
                      <span class="text-cyan-300">&lt;.input</span>
                      <span class="text-amber-300">name=</span><span class="text-emerald-300">"email"</span>
                      <span class="text-amber-300">label=</span><span class="text-emerald-300">"Email"</span>
                      <span class="text-cyan-300">/&gt;</span>
                    </span>
                    <span class="block pl-8">
                      <span class="text-cyan-300">&lt;/div&gt;</span>
                    </span>
                    <span class="block pl-8">
                      <span class="text-amber-300">&quot;&quot;&quot;</span>
                    </span>
                    <span class="block pl-4"><span class="text-fuchsia-300">end</span></span>
                    <span class="block"><span class="text-fuchsia-300">end</span></span>
                  </.code_panel>
                </div>
              </div>
            </div>

            <div class="rounded-3xl bg-background/90 p-6">
              <div class="flex flex-col gap-6 lg:grid lg:grid-cols-2 lg:items-start">
                <div>
                  <div class="text-xs font-semibold uppercase tracking-[0.2em] text-primary/80">
                    Step 03
                  </div>
                  <h3 class="mt-3 text-xl font-semibold tracking-tight">Open the docs</h3>
                  <p class="mt-3 text-sm leading-6 text-foreground/65">
                    Use the docs site for interactive demos, usage notes, and the complete API
                    reference.
                  </p>
                </div>

                <div class="w-full rounded-2xl border border-border bg-card px-5 py-5">
                  <p class="text-sm font-semibold">Choose your path</p>
                  <p class="mt-2 text-sm leading-6 text-foreground/65">
                    Start with the local docs, then jump to the hosted package docs when you want the
                    published reference.
                  </p>

                  <div class="mt-4 flex flex-wrap gap-3">
                    <.button navigate={~p"/docs"}>
                      <.icon name="hero-book-open" class="size-4" /> Docs
                    </.button>
                    <.button
                      variant="outline"
                      href={hexdocs_url()}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <.icon name="hero-arrow-top-right-on-square" class="size-4" /> HexDocs
                    </.button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="mx-auto max-w-7xl px-6 pb-16 lg:px-8">
        <div class="max-w-2xl">
          <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Features</p>
          <h2 class="mt-4 text-3xl font-semibold tracking-tight">
            A straightforward toolkit for shipping cleaner LiveView interfaces.
          </h2>
          <p class="mt-4 text-base leading-7 text-foreground/70">
            PUI stays small on the surface, but still gives you the pieces you need to build cohesive
            UI quickly.
          </p>
        </div>

        <div class="mt-8 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <div
            :for={feature <- feature_cards()}
            class="rounded-3xl border border-border bg-card p-6 shadow-sm"
          >
            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <.icon name={feature.icon} class="size-5" />
            </div>
            <h3 class="mt-6 text-xl font-semibold tracking-tight">{feature.title}</h3>
            <p class="mt-3 text-sm leading-7 text-foreground/65">{feature.description}</p>
          </div>
        </div>
      </section>

      <footer class="border-t border-border/80 bg-muted/20">
        <div class="mx-auto max-w-7xl px-6 py-16 lg:px-8">
          <div class="rounded-[2rem] border border-border bg-card p-8 shadow-sm">
            <p class="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Next steps</p>
            <h2 class="mt-4 text-2xl font-semibold tracking-tight">
              Explore PUI from the channel that fits your workflow.
            </h2>
            <p class="mt-4 max-w-2xl text-base leading-7 text-foreground/70">
              Browse the local docs, read the published package docs, inspect the Hex package, or go
              straight to the repository.
            </p>

            <div class="mt-6 flex flex-wrap gap-3">
              <.button navigate={~p"/docs"}>
                <.icon name="hero-book-open" class="size-4" /> Docs
              </.button>
              <.button
                variant="outline"
                href={hexdocs_url()}
                target="_blank"
                rel="noopener noreferrer"
              >
                <.icon name="hero-arrow-top-right-on-square" class="size-4" /> HexDocs
              </.button>
              <.button
                variant="outline"
                href={hexpm_url()}
                target="_blank"
                rel="noopener noreferrer"
              >
                <.icon name="hero-cube" class="size-4" /> Hex.pm
              </.button>
              <.button
                variant="outline"
                href={source_code_url()}
                target="_blank"
                rel="noopener noreferrer"
              >
                <.icon name="hero-code-bracket" class="size-4" /> Source code
              </.button>
            </div>
          </div>
        </div>
      </footer>
    </div>
    """
  end

  attr :title, :string, required: true
  slot :inner_block, required: true

  defp code_panel(assigns) do
    ~H"""
    <div class="overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-950 shadow-sm">
      <div class="flex items-center gap-2 border-b border-white/10 px-4 py-3 text-xs text-zinc-400">
        <span class="h-2 w-2 rounded-full bg-red-400" />
        <span class="h-2 w-2 rounded-full bg-amber-400" />
        <span class="h-2 w-2 rounded-full bg-emerald-400" />
        <span class="ml-2 font-medium text-zinc-300">{@title}</span>
      </div>
      <div class="overflow-x-auto px-4 py-5">
        <code class="block min-w-max font-mono text-sm leading-7">{render_slot(@inner_block)}</code>
      </div>
    </div>
    """
  end

  defp feature_cards do
    [
      %{
        icon: "hero-bolt",
        title: "Built for LiveView",
        description:
          "Use components that feel natural in LiveViews and function components, without pulling in a heavy frontend layer."
      },
      %{
        icon: "hero-shield-check",
        title: "Accessible interactions",
        description:
          "Start from components that already consider focus, states, and common interaction patterns."
      },
      %{
        icon: "hero-swatch",
        title: "Theme-ready defaults",
        description:
          "Keep the defaults minimal, then adapt them to your product without fighting the styling system."
      },
      %{
        icon: "hero-book-open",
        title: "Docs-first workflow",
        description:
          "Use `/docs` as the main place for interactive examples, usage notes, and API references."
      }
    ]
  end

  defp hero_tags do
    ["LiveView-native", "Accessible by default", "Theme-ready", "Docs-first"]
  end

  defp source_code_url, do: "https://github.com/suciptoid/pui"
  defp hexdocs_url, do: "https://hexdocs.pm/pui"
  defp hexpm_url, do: "https://hex.pm/packages/pui"
end
