defmodule AppWeb.Live.DemoTab do
  use AppWeb, :live_view
  use PUI

  import AppWeb.DocComponents

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(count: 0, active_tab: "account")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("incr", _, socket) do
    {:noreply, socket |> assign(count: socket.assigns.count + 1)}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(active_tab: tab)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="space-y-8">
        <%!-- Page Header --%>
        <div>
          <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">Tabs</h1>
          <p class="text-muted-foreground mt-2">
            Tab components for organizing content into navigable sections.
            Includes examples using colocated hooks for client-side interactions.
          </p>
        </div>

        <%!-- Basic Tabs --%>
        <.example_card
          title="Basic Tabs"
          description="Simple tab navigation with active state managed by LiveView."
        >
          <div class="space-y-4">
            <div class="border-b border-border">
              <nav class="flex gap-1" aria-label="Tabs">
                <button
                  :for={tab <- ["account", "password", "notifications"]}
                  phx-click="switch_tab"
                  phx-value-tab={tab}
                  class={[
                    "px-4 py-2 text-sm font-medium border-b-2 transition-colors",
                    @active_tab == tab &&
                      "border-primary text-primary",
                    @active_tab != tab &&
                      "border-transparent text-muted-foreground hover:text-foreground hover:border-border"
                  ]}
                >
                  {String.capitalize(tab)}
                </button>
              </nav>
            </div>
            <div class="p-4 rounded-lg bg-muted/50">
              <p class="text-sm text-muted-foreground">
                Active tab: <span class="font-semibold text-foreground">{@active_tab}</span>
              </p>
            </div>
            <.code_block
              code={"<div class=\"border-b border-border\">\n  <nav class=\"flex gap-1\" aria-label=\"Tabs\">\n    <button\n      :for={tab <- [\"account\", \"password\", \"notifications\"]}\n      phx-click=\"switch_tab\"\n      phx-value-tab={tab}\n      class={[\n        \"px-4 py-2 text-sm font-medium border-b-2\",\n        @active_tab == tab && \\\n          \"border-primary text-primary\",\n        @active_tab != tab && \\\n          \"border-transparent text-muted-foreground\"\n      ]}\n    >\n      {String.capitalize(tab)}\n    </button>\n  </nav>\n</div>"}
              language="heex"
            />
          </div>
        </.example_card>

        <%!-- Tabs with Content --%>
        <.example_card
          title="Tabs with Content"
          description="Tabs that display different content based on the active tab."
        >
          <div class="space-y-4">
            <div class="border-b border-border">
              <nav class="flex gap-1" aria-label="Tabs">
                <button
                  :for={
                    {id, label} <- [
                      {"profile", "Profile"},
                      {"settings", "Settings"},
                      {"messages", "Messages"}
                    ]
                  }
                  phx-click="switch_tab"
                  phx-value-tab={id}
                  class={[
                    "px-4 py-2 text-sm font-medium border-b-2 transition-colors flex items-center gap-2",
                    @active_tab == id &&
                      "border-primary text-primary",
                    @active_tab != id &&
                      "border-transparent text-muted-foreground hover:text-foreground hover:border-border"
                  ]}
                >
                  <.icon
                    :if={id == "profile"}
                    name="hero-user"
                    class="size-4"
                  />
                  <.icon
                    :if={id == "settings"}
                    name="hero-cog"
                    class="size-4"
                  />
                  <.icon
                    :if={id == "messages"}
                    name="hero-chat-bubble-left"
                    class="size-4"
                  />
                  {label}
                </button>
              </nav>
            </div>
            <div class="p-6 rounded-lg border border-border bg-card min-h-[120px]">
              <div :if={@active_tab in ["profile", "account"]} class="space-y-2">
                <h3 class="font-semibold">Profile Settings</h3>
                <p class="text-sm text-muted-foreground">
                  Manage your profile information and public visibility.
                </p>
              </div>
              <div :if={@active_tab == "settings"} class="space-y-2">
                <h3 class="font-semibold">General Settings</h3>
                <p class="text-sm text-muted-foreground">
                  Configure your application preferences and defaults.
                </p>
              </div>
              <div :if={@active_tab == "messages"} class="space-y-2">
                <h3 class="font-semibold">Messages</h3>
                <p class="text-sm text-muted-foreground">
                  View and manage your conversations.
                </p>
              </div>
              <div
                :if={@active_tab not in ["profile", "account", "settings", "messages"]}
                class="space-y-2"
              >
                <h3 class="font-semibold">{String.capitalize(@active_tab)}</h3>
                <p class="text-sm text-muted-foreground">
                  Content for the {@active_tab} tab goes here.
                </p>
              </div>
            </div>
            <.code_block
              code={"<div class=\"border-b border-border\">\n  <nav class=\"flex gap-1\" aria-label=\"Tabs\">\n    <button\n      phx-click=\"switch_tab\"\n      phx-value-tab=\"profile\"\n      class={[\n        \"px-4 py-2 text-sm font-medium\",\n        @active_tab == \"profile\" && \\\n          \"border-b-2 border-primary text-primary\",\n        @active_tab != \"profile\" && \\\n          \"text-muted-foreground hover:text-foreground\"\n      ]}\n    >\n      Profile\n    </button>\n  </nav>\n</div>\n\n<div class=\"p-6 rounded-lg border border-border\">\n  <div :if={@active_tab == \"profile\"}>\n    Profile content here...\n  </div>\n</div>"}
              language="heex"
            />
          </div>
        </.example_card>

        <%!-- Tab Navigation --%>
        <.example_card
          title="Tab Navigation"
          description="Pill-style tab navigation for a different visual style."
        >
          <div class="space-y-4">
            <nav class="flex gap-2 p-1 rounded-lg bg-muted w-fit" aria-label="Pill Tabs">
              <button
                :for={
                  {id, label} <- [
                    {"overview", "Overview"},
                    {"analytics", "Analytics"},
                    {"reports", "Reports"}
                  ]
                }
                phx-click="switch_tab"
                phx-value-tab={id}
                class={[
                  "px-4 py-2 text-sm font-medium rounded-md transition-all",
                  @active_tab == id &&
                    "bg-background text-foreground shadow-sm",
                  @active_tab != id &&
                    "text-muted-foreground hover:text-foreground"
                ]}
              >
                {label}
              </button>
            </nav>
            <.code_block
              code={"<nav class=\"flex gap-2 p-1 rounded-lg bg-muted w-fit\">\n  <button\n    :for={{id, label} <- [{\"overview\", \"Overview\"}, ...]}\n    phx-click=\"switch_tab\"\n    phx-value-tab={id}\n    class={[\n      \"px-4 py-2 text-sm font-medium rounded-md\",\n      @active_tab == id && \\\n        \"bg-background text-foreground shadow-sm\",\n      @active_tab != id && \\\n        \"text-muted-foreground hover:text-foreground\"\n    ]}\n  >\n    {label}\n  </button>\n</nav>"}
              language="heex"
            />
          </div>
        </.example_card>

        <%!-- Colocated Hook Demo --%>
        <.example_card
          title="Colocated Hooks"
          description="Example of using colocated hooks with tabs for client-side interactions."
        >
          <div class="space-y-4">
            <p class="text-sm text-muted-foreground">
              This example demonstrates Phoenix LiveView's colocated hooks feature,
              allowing JavaScript hooks to be defined directly in the template.
              Click the button to trigger client-side logging.
            </p>
            <div id="tab-hok" phx-hook=".TabHook" class="p-4 rounded-lg border border-border bg-card">
              <.button phx-click="incr">
                <.icon name="hero-plus" class="size-4 mr-2" /> Count: {@count}
              </.button>
            </div>
            <.code_block
              code={"<div id=\"tab-hok\" phx-hook=\".TabHook\">\n  <.button phx-click=\"incr\">\n    Count: {@count}\n  </.button>\n</div>\n\n<script :type={Phoenix.LiveView.ColocatedHook} name=\".TabHook\">\n  export default {\n    mounted() {\n      console.log(\"hook mounted\")\n    },\n    beforeUpdate(from, to) {\n      console.log(\"hook updated\", {from, to})\n    }\n  }\n</script>"}
              language="heex"
            />
          </div>
        </.example_card>

        <%!-- Props Table --%>
        <.example_card
          title="Implementation Notes"
          description="Tips for building tab interfaces with Maui components."
        >
          <div class="space-y-4 text-sm text-zinc-600 dark:text-zinc-400">
            <div>
              <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">State Management</h4>
              <p>
                Use LiveView state (<code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-700 rounded">@active_tab</code>)
                to track the currently selected tab. Send
                <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-700 rounded">phx-click</code>
                events to switch tabs.
              </p>
            </div>
            <div>
              <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">Accessibility</h4>
              <p>
                Include
                <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-700 rounded">
                  aria-label="Tabs"
                </code>
                on the navigation container and use proper button elements for keyboard navigation support.
              </p>
            </div>
            <div>
              <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">Styling</h4>
              <p>
                Use Tailwind's conditional classes with the
                <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-700 rounded">class</code>
                attribute and the
                <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-700 rounded">&&</code>
                operator
                for active/inactive states.
              </p>
            </div>
          </div>
        </.example_card>

        <%!-- Hidden Colocated Hook Script --%>
        <script :type={Phoenix.LiveView.ColocatedHook} name=".TabHook">
          export default {
            mounted() {
              console.log("tabhook mounted")
            },
            beforeUpdate(from, to) {
              console.log("hook updated", {from, to})
            }
          }
        </script>
      </div>
    </Layouts.docs>
    """
  end
end
