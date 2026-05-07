defmodule AppWeb.Live.LandingLive do
  @moduledoc """
  Landing page - Clean white with blue-200 top gradient, dashboard demo, features, CTA.
  """
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
    <div class="min-h-screen bg-white text-foreground dark:bg-gray-950">
      <div class="relative isolate overflow-hidden">
        <div class="absolute inset-x-0 top-0 -z-10 h-[48rem] bg-gradient-to-b from-blue-200 to-transparent dark:from-blue-500/10" />

        <header class="mx-auto flex max-w-7xl items-center justify-between px-6 py-5 lg:px-8">
          <.link navigate={~p"/"} class="flex items-center gap-3 group">
            <div class="flex h-10 w-10 items-center justify-center rounded-2xl border border-gray-200 bg-white shadow-sm transition-shadow group-hover:shadow-md dark:border-gray-700 dark:bg-gray-900">
              <img src={~p"/images/pui-hook-2d.png"} alt="PUI" class="h-7 w-7" />
            </div>
            <span class="text-lg font-bold tracking-tight">PUI</span>
          </.link>

          <div class="flex items-center gap-2">
            <.button
              navigate={~p"/docs"}
              variant="outline"
              size="sm"
              class="border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
            >
              <.icon name="hero-book-open" class="size-3.5" /> Docs
            </.button>
            <.button
              variant="outline"
              size="sm"
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
            >
              <.icon name="hero-code-bracket" class="size-3.5" /> GitHub
            </.button>
          </div>
        </header>

        <%!-- Hero --%>
        <main class="mx-auto max-w-4xl px-6 pt-12 pb-20 text-center lg:px-8 lg:pt-20 lg:pb-28">
          <div class="inline-flex items-center gap-2 rounded-full border border-blue-500/25 bg-blue-600/10 px-3.5 py-1.5 text-xs font-semibold uppercase tracking-[0.18em] text-blue-700 dark:border-blue-400/25 dark:bg-blue-500/15 dark:text-blue-100">
            <span class="h-1.5 w-1.5 rounded-full bg-primary animate-pulse" /> v1.0.0 beta
          </div>

          <h1 class="mt-6 text-5xl font-bold tracking-tight leading-[1.1] text-gray-900 dark:text-gray-50 sm:text-6xl lg:text-7xl">
            Build polished interfaces
            <span class="text-blue-600 dark:text-blue-400">without the busywork.</span>
          </h1>

          <p class="mt-6 max-w-xl mx-auto text-lg leading-8 text-gray-600 dark:text-gray-400">
            PUI gives you accessible, theme-ready LiveView components so you can
            ship consistent product UI faster.
          </p>

          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <.button
              navigate={~p"/docs"}
              size="lg"
              class="border-blue-500 bg-blue-600 text-white shadow-lg shadow-blue-700/25 hover:bg-blue-700"
            >
              <.icon name="hero-book-open" class="size-4" /> Read the docs
            </.button>
            <.button
              variant="outline"
              size="lg"
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-100 dark:hover:bg-gray-800"
            >
              <.icon name="hero-code-bracket" class="size-4" /> Source code
            </.button>
          </div>
        </main>
      </div>

      <%!-- Dashboard demo --%>
      <section class="relative z-10 mx-auto -mt-16 max-w-7xl px-6 pb-20 lg:-mt-20 lg:px-8 lg:pb-28">
        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-xl shadow-gray-950/8 dark:border-gray-800 dark:bg-gray-900">
          <div class="flex h-[600px] bg-white dark:bg-gray-900">
            <div class="hidden w-60 shrink-0 border-r border-gray-200 bg-white sm:flex flex-col dark:border-gray-800 dark:bg-gray-900">
              <div class="flex items-center gap-2.5 border-b border-gray-200 px-4 py-3.5 dark:border-gray-800">
                <div class="flex h-7 w-7 items-center justify-center rounded-md bg-gray-100 dark:bg-gray-800">
                  <.icon name="hero-chart-bar" class="size-3.5 text-primary" />
                </div>
                <div>
                  <p class="text-xs font-bold text-gray-900 dark:text-gray-50">FinanceOS</p>
                  <p class="text-[10px] text-gray-500 dark:text-gray-500">Workspace</p>
                </div>
              </div>
              <nav class="flex-1 p-3 space-y-0.5">
                <div
                  :for={item <- sidebar_items()}
                  class={[
                    "flex items-center gap-2.5 rounded-md px-2.5 py-2 text-xs font-medium",
                    item.active &&
                      "bg-gray-100 text-gray-900 dark:bg-gray-800 dark:text-gray-100",
                    !item.active &&
                      "text-gray-500 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-800/60 dark:hover:text-gray-50"
                  ]}
                >
                  <.icon name={item.icon} class="size-3.5" />{item.label}
                </div>
              </nav>
              <div class="border-t border-gray-200 p-3 dark:border-gray-800">
                <div class="flex items-center gap-2.5 rounded-md px-2.5 py-2">
                  <div class="flex h-6 w-6 items-center justify-center rounded-md bg-gray-100 text-[10px] font-bold text-gray-600 dark:bg-gray-700 dark:text-gray-300">
                    S
                  </div>
                  <div>
                    <p class="text-xs font-medium text-gray-900 dark:text-gray-50">Sucipto</p>
                    <p class="text-[10px] text-gray-500 dark:text-gray-500">Developer</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="flex-1 flex flex-col min-w-0">
              <div class="flex items-center justify-between border-b border-gray-200 px-5 py-3 dark:border-gray-800">
                <div>
                  <p class="text-[10px] font-semibold uppercase tracking-[0.18em] text-gray-500 dark:text-gray-400">
                    Dashboard
                  </p>
                  <p class="text-sm font-semibold text-gray-900 dark:text-gray-50">Overview</p>
                </div>
                <div class="flex gap-2">
                  <.button
                    variant="outline"
                    size="sm"
                    class="border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
                  >
                    <.icon name="hero-arrow-down-tray" class="size-3" /> Export
                  </.button>
                  <.button size="sm" class="border-blue-500 bg-blue-600 text-white hover:bg-blue-700">
                    <.icon name="hero-plus" class="size-3" /> New
                  </.button>
                </div>
              </div>
              <div class="flex-1 overflow-y-auto p-5 space-y-5">
                <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
                  <div
                    :for={m <- shell_metrics()}
                    class="rounded-lg border border-gray-200 bg-white p-3.5 shadow-sm shadow-gray-950/5 dark:border-gray-800 dark:bg-gray-900"
                  >
                    <p class="text-[10px] font-medium text-gray-500 dark:text-gray-400">
                      {m.label}
                    </p>
                    <p class="mt-1 text-xl font-bold tracking-tight text-gray-900 dark:text-gray-50">
                      {m.value}
                    </p>
                    <p class={[
                      "mt-0.5 text-[10px] font-medium",
                      m.positive && "text-emerald-500",
                      !m.positive && "text-red-500"
                    ]}>
                      {m.change}
                    </p>
                  </div>
                </div>
                <div class="grid gap-5 xl:grid-cols-[1.2fr_1fr]">
                  <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm shadow-gray-950/5 dark:border-gray-800 dark:bg-gray-900">
                    <p class="mb-3 text-xs font-semibold text-gray-500 dark:text-gray-400">
                      Revenue trend
                    </p>
                    <.line_chart
                      id="demo-chart-main"
                      card={false}
                      height={200}
                      labels={["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"]}
                      series={[
                        %{label: "Revenue", data: [42, 48, 45, 52, 58, 64], suffix: "k"},
                        %{label: "Target", data: [40, 40, 50, 50, 60, 60], suffix: "k"}
                      ]}
                    />
                  </div>
                  <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm shadow-gray-950/5 dark:border-gray-800 dark:bg-gray-900">
                    <p class="mb-3 text-xs font-semibold text-gray-500 dark:text-gray-400">
                      By channel
                    </p>
                    <.bar_chart
                      id="demo-chart-bar"
                      card={false}
                      height={200}
                      categories={["Direct", "Referral", "Organic", "Paid"]}
                      series={[
                        %{label: "Revenue", data: [24, 18, 32, 14], suffix: "k"}
                      ]}
                      tooltip={%{}}
                    />
                  </div>
                </div>
                <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm shadow-gray-950/5 dark:border-gray-800 dark:bg-gray-900">
                  <p class="mb-3 text-xs font-semibold text-gray-500 dark:text-gray-400">
                    Recent activity
                  </p>
                  <div class="space-y-2.5">
                    <div :for={a <- shell_activity()} class="flex items-center gap-3 py-1.5">
                      <div class="flex h-7 w-7 shrink-0 items-center justify-center rounded-md bg-gray-100 text-gray-500 dark:bg-gray-800 dark:text-gray-400">
                        <.icon name={a.icon} class="size-3.5" />
                      </div>
                      <p class="flex-1 truncate text-xs text-gray-600 dark:text-gray-400">
                        {a.text}
                      </p>
                      <span class="shrink-0 text-[10px] text-gray-400 dark:text-gray-500">
                        {a.time}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- Features --%>
      <section class="mx-auto max-w-7xl px-6 pb-20 lg:px-8 lg:pb-28">
        <div class="text-center mb-10">
          <p class="text-xs font-semibold uppercase tracking-[0.2em] text-blue-600 dark:text-blue-400">
            Features
          </p>
          <h2 class="mt-3 text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-50 sm:text-3xl">
            Everything you need, nothing you don't.
          </h2>
        </div>
        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <div
            :for={f <- feature_cards()}
            class="group rounded-2xl border border-gray-200 bg-white p-6 transition-all hover:border-gray-300 hover:shadow-md hover:shadow-gray-950/8 dark:border-gray-800 dark:bg-gray-900 dark:hover:border-gray-700"
          >
            <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600 transition-transform group-hover:scale-110 dark:bg-blue-500/15 dark:text-blue-400">
              <.icon name={f.icon} class="size-5" />
            </div>
            <h3 class="mt-5 text-base font-semibold text-gray-900 dark:text-gray-50">{f.title}</h3>
            <p class="mt-2 text-sm leading-6 text-gray-600 dark:text-gray-400">{f.description}</p>
          </div>
        </div>
      </section>

      <%!-- CTA --%>
      <section class="mx-auto max-w-7xl px-6 pb-20 lg:px-8 lg:pb-28">
        <div class="relative overflow-hidden rounded-3xl border border-gray-200 bg-white p-8 text-center dark:border-gray-800 dark:bg-gray-900 lg:p-14">
          <h2 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-gray-50 sm:text-3xl">
            Ready to get started?
          </h2>
          <p class="mx-auto mt-3 max-w-md text-base leading-7 text-gray-600 dark:text-gray-400">
            Add PUI to your Phoenix LiveView project and start building polished interfaces today.
          </p>
          <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
            <.button
              navigate={~p"/docs"}
              size="lg"
              class="border-blue-500 bg-blue-600 text-white shadow-lg shadow-blue-700/25 hover:bg-blue-700"
            >
              <.icon name="hero-book-open" class="size-4" /> Read the docs
            </.button>
            <.button
              variant="outline"
              size="lg"
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
            >
              <.icon name="hero-code-bracket" class="size-4" /> View on GitHub
            </.button>
          </div>
        </div>
      </section>

      <footer class="border-t border-gray-200 dark:border-gray-800">
        <div class="mx-auto flex max-w-7xl flex-col gap-4 px-6 py-10 sm:flex-row sm:items-center sm:justify-between lg:px-8">
          <p class="text-sm text-gray-500 dark:text-gray-500">Built with Phoenix LiveView.</p>
          <div class="flex gap-5">
            <.link
              navigate={~p"/docs"}
              class="text-sm text-gray-500 transition-colors hover:text-gray-900 dark:hover:text-gray-50"
            >
              Docs
            </.link>
            <a
              href={source_code_url()}
              target="_blank"
              rel="noopener noreferrer"
              class="text-sm text-gray-500 transition-colors hover:text-gray-900 dark:hover:text-gray-50"
            >
              GitHub
            </a>
          </div>
        </div>
      </footer>
    </div>
    """
  end

  defp sidebar_items do
    [
      %{icon: "hero-home", label: "Dashboard", active: true},
      %{icon: "hero-chart-bar", label: "Analytics", active: false},
      %{icon: "hero-banknotes", label: "Invoices", active: false},
      %{icon: "hero-user-group", label: "Customers", active: false},
      %{icon: "hero-cog-6-tooth", label: "Settings", active: false}
    ]
  end

  defp shell_metrics do
    [
      %{label: "Revenue", value: "$64.2k", change: "+12.5%", positive: true},
      %{label: "Customers", value: "1,284", change: "+8.3%", positive: true},
      %{label: "Avg. order", value: "$142", change: "-2.1%", positive: false},
      %{label: "Churn", value: "1.2%", change: "-0.4%", positive: true}
    ]
  end

  defp shell_activity do
    [
      %{icon: "hero-banknotes", text: "Payment received from Acme Corp", time: "2m ago"},
      %{icon: "hero-user-plus", text: "New customer: Globex Inc", time: "15m ago"},
      %{icon: "hero-document-check", text: "Invoice #1042 marked as paid", time: "1h ago"},
      %{icon: "hero-arrow-trending-up", text: "Revenue milestone reached", time: "3h ago"}
    ]
  end

  defp feature_cards do
    [
      %{
        icon: "hero-bolt",
        title: "Built for LiveView",
        description:
          "Components that feel natural in LiveViews and function components, without a heavy frontend layer."
      },
      %{
        icon: "hero-shield-check",
        title: "Accessible by default",
        description:
          "Focus management, keyboard navigation, and ARIA attributes baked in from the start."
      },
      %{
        icon: "hero-swatch",
        title: "Theme-ready",
        description:
          "CSS variables for colors, spacing, and radius. Override what you need, keep the rest."
      },
      %{
        icon: "hero-cube",
        title: "Small footprint",
        description:
          "One dependency, minimal JS hooks, no external CSS framework required beyond Tailwind."
      }
    ]
  end

  defp source_code_url, do: "https://github.com/suciptoid/pui"
end
