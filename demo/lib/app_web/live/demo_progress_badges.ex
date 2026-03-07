defmodule AppWeb.Live.DemoProgressBadges do
  use AppWeb, :live_view
  use Maui
  import AppWeb.DocComponents

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_value, 35)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("update_progress", %{"value" => value}, socket) do
    new_value = String.to_integer(value)
    {:noreply, socket |> assign(:current_value, new_value)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={:progress_badges}>
      <div class="space-y-8">
        <!-- Page Header -->
        <div>
          <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">Progress & Badges</h1>
          <p class="mt-2 text-zinc-600 dark:text-zinc-400">
            Visual indicators for tasks, loading states, and status descriptors.
          </p>
        </div>

        <!-- Interactive Progress Bar -->
        <.example_card
          title="Interactive Progress Bar"
          description="Progress bars with interactive slider control. Adjust the value to see the progress update in real-time."
        >
          <div class="space-y-6">
            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-zinc-600 dark:text-zinc-400">Progress</span>
                <span class="font-medium text-zinc-900 dark:text-zinc-100">{@current_value}%</span>
              </div>
              <Maui.Components.progress value={@current_value / 1} min={0.0} max={100.0} class="h-2" />
            </div>

            <div class="flex items-center gap-4">
              <span class="text-sm text-zinc-500">0%</span>
              <input
                type="range"
                min="0"
                max="100"
                value={@current_value}
                phx-change="update_progress"
                class="flex-1 h-2 bg-zinc-200 dark:bg-zinc-700 rounded-lg appearance-none cursor-pointer accent-primary"
              />
              <span class="text-sm text-zinc-500">100%</span>
            </div>

            <div class="flex gap-2">
              <.button size="sm" variant="outline" phx-click="update_progress" phx-value-value="0">0%</.button>
              <.button size="sm" variant="outline" phx-click="update_progress" phx-value-value="25">25%</.button>
              <.button size="sm" variant="outline" phx-click="update_progress" phx-value-value="50">50%</.button>
              <.button size="sm" variant="outline" phx-click="update_progress" phx-value-value="75">75%</.button>
              <.button size="sm" variant="outline" phx-click="update_progress" phx-value-value="100">100%</.button>
            </div>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Components.progress
  value={@current_value}
  min={0.0}
  max={100.0}
  class="h-2"
/>

<input
  type="range"
  min="0"
  max="100"
  value={@current_value}
  phx-change="update_progress"
/>|}
            />
          </div>
        </.example_card>

        <!-- Custom Min/Max Progress -->
        <.example_card
          title="Custom Min/Max Progress"
          description="Progress bars with custom minimum and maximum values for non-percentage ranges."
        >
          <div class="space-y-6">
            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-zinc-600 dark:text-zinc-400">Storage Used (50-200 GB)</span>
                <span class="font-medium text-zinc-900 dark:text-zinc-100">75 GB</span>
              </div>
              <Maui.Components.progress value={75.0} min={50.0} max={200.0} class="h-3" />
            </div>

            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-zinc-600 dark:text-zinc-400">Download Progress (0-50 MB)</span>
                <span class="font-medium text-zinc-900 dark:text-zinc-100">32 MB</span>
              </div>
              <Maui.Components.progress value={32.0} min={0.0} max={50.0} class="h-3" />
            </div>

            <div class="space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-zinc-600 dark:text-zinc-400">Temperature (0-100°C)</span>
                <span class="font-medium text-zinc-900 dark:text-zinc-100">68°C</span>
              </div>
              <Maui.Components.progress value={68.0} min={0.0} max={100.0} class="h-3" />
            </div>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Components.progress
  value={75.0}
  min={50.0}
  max={200.0}
  class="h-3"
/>

<Maui.Components.progress
  value={32.0}
  min={0.0}
  max={50.0}
  class="h-3"
/>|}
            />
          </div>
        </.example_card>

        <!-- Badge Variants -->
        <.example_card
          title="Badge Variants"
          description="Small status indicators with different semantic meanings."
        >
          <div class="flex flex-wrap gap-3">
            <Maui.Components.badge variant="default">Default</Maui.Components.badge>
            <Maui.Components.badge variant="secondary">Secondary</Maui.Components.badge>
            <Maui.Components.badge variant="destructive">Destructive</Maui.Components.badge>
            <Maui.Components.badge variant="outline">Outline</Maui.Components.badge>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Components.badge variant="default">Default</Maui.Components.badge>
<Maui.Components.badge variant="secondary">Secondary</Maui.Components.badge>
<Maui.Components.badge variant="destructive">Destructive</Maui.Components.badge>
<Maui.Components.badge variant="outline">Outline</Maui.Components.badge>|}
            />
          </div>
        </.example_card>

        <!-- Custom Styled Badges -->
        <.example_card
          title="Custom Styled Badges"
          description="Badges with custom colors using Tailwind classes."
        >
          <div class="space-y-4">
            <div class="flex flex-wrap gap-3">
              <Maui.Components.badge class="bg-blue-500 hover:bg-blue-600 text-white">
                <.icon name="hero-check-circle" class="w-3 h-3 mr-1" />
                Verified
              </Maui.Components.badge>
              <Maui.Components.badge class="bg-green-500 hover:bg-green-600 text-white">
                <.icon name="hero-signal" class="w-3 h-3 mr-1" />
                Online
              </Maui.Components.badge>
              <Maui.Components.badge class="bg-purple-500 hover:bg-purple-600 text-white">
                <.icon name="hero-sparkles" class="w-3 h-3 mr-1" />
                Pro
              </Maui.Components.badge>
              <Maui.Components.badge class="bg-orange-500 hover:bg-orange-600 text-white">
                <.icon name="hero-clock" class="w-3 h-3 mr-1" />
                Pending
              </Maui.Components.badge>
            </div>

            <div class="flex flex-wrap gap-3">
              <Maui.Components.badge class="bg-zinc-100 text-zinc-700 border border-zinc-200">
                Draft
              </Maui.Components.badge>
              <Maui.Components.badge class="bg-yellow-100 text-yellow-800 border border-yellow-200">
                Warning
              </Maui.Components.badge>
              <Maui.Components.badge class="bg-red-100 text-red-800 border border-red-200">
                Error
              </Maui.Components.badge>
            </div>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Components.badge class="bg-blue-500 hover:bg-blue-600 text-white">
  <.icon name="hero-check-circle" class="w-3 h-3 mr-1" />
  Verified
</Maui.Components.badge>

<Maui.Components.badge class="bg-green-500 hover:bg-green-600 text-white">
  <.icon name="hero-signal" class="w-3 h-3 mr-1" />
  Online
</Maui.Components.badge>

<Maui.Components.badge class="bg-zinc-100 text-zinc-700 border border-zinc-200">
  Draft
</Maui.Components.badge>|}
            />
          </div>
        </.example_card>

        <!-- Badges in Context -->
        <.example_card
          title="Badges in Context"
          description="Real-world usage examples showing badges in different UI contexts."
        >
          <div class="space-y-4">
            <div class="flex items-center justify-between p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-zinc-200 dark:bg-zinc-700 rounded-full flex items-center justify-center">
                  <.icon name="hero-user" class="w-5 h-5 text-zinc-500" />
                </div>
                <div>
                  <p class="font-medium text-zinc-900 dark:text-zinc-100">Sarah Johnson</p>
                  <p class="text-sm text-zinc-500">sarah@example.com</p>
                </div>
              </div>
              <Maui.Components.badge variant="secondary">Active</Maui.Components.badge>
            </div>

            <div class="flex items-center justify-between p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-zinc-200 dark:bg-zinc-700 rounded-full flex items-center justify-center">
                  <.icon name="hero-server" class="w-5 h-5 text-zinc-500" />
                </div>
                <div>
                  <p class="font-medium text-zinc-900 dark:text-zinc-100">Production Server</p>
                  <p class="text-sm text-zinc-500">192.168.1.100</p>
                </div>
              </div>
              <Maui.Components.badge class="bg-green-500 text-white">Healthy</Maui.Components.badge>
            </div>

            <div class="flex items-center justify-between p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-zinc-200 dark:bg-zinc-700 rounded-full flex items-center justify-center">
                  <.icon name="hero-document-text" class="w-5 h-5 text-zinc-500" />
                </div>
                <div>
                  <p class="font-medium text-zinc-900 dark:text-zinc-100">Quarterly Report.pdf</p>
                  <p class="text-sm text-zinc-500">2.4 MB · Uploaded yesterday</p>
                </div>
              </div>
              <Maui.Components.badge variant="outline">Pending Review</Maui.Components.badge>
            </div>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<div class="flex items-center justify-between p-3 bg-zinc-50 rounded-lg">
  <div class="flex items-center gap-3">
    <.icon name="hero-user" class="w-5 h-5" />
    <span>Sarah Johnson</span>
  </div>
  <Maui.Components.badge variant="secondary">Active</Maui.Components.badge>
</div>|}
            />
          </div>
        </.example_card>

        <!-- Progress Props Table -->
        <div>
          <h2 class="text-xl font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Progress Props</h2>
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <.props_table
              props={[
                %{name: "value", type: "float", default: "0.0", description: "Current progress value"},
                %{name: "min", type: "float", default: "0.0", description: "Minimum value of the range"},
                %{name: "max", type: "float", default: "100.0", description: "Maximum value of the range"},
                %{name: "class", type: "string", default: "nil", description: "Additional CSS classes for the container"}
              ]}
            />
          </div>
        </div>

        <!-- Badge Props Table -->
        <div>
          <h2 class="text-xl font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Badge Props</h2>
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <.props_table
              props={[
                %{name: "variant", type: "string", default: "default", description: "Badge style (default, secondary, destructive, outline)"},
                %{name: "class", type: "string", default: "nil", description: "Additional CSS classes"}
              ]}
            />
          </div>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
