defmodule AppWeb.Live.DemoContainer do
  use AppWeb, :live_view
  use Maui
  import AppWeb.DocComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="space-y-8">
        <!-- Page Header -->
        <div>
          <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">Container Components</h1>
          <p class="mt-2 text-zinc-600 dark:text-zinc-400">
            Maui provides various container components for organizing content with consistent styling.
          </p>
        </div>
        
    <!-- Basic Card -->
        <.example_card
          title="Basic Card"
          description="A simple card component with default styling for containing content."
        >
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Maui.Container.card>
              <p class="text-zinc-700 dark:text-zinc-300">
                This is a basic card with default styling. It provides a clean container for any content.
              </p>
            </Maui.Container.card>

            <Maui.Container.card class="bg-blue-50 dark:bg-blue-950/30 border-blue-200 dark:border-blue-800">
              <p class="text-blue-900 dark:text-blue-100">
                This card has custom styling applied via the class attribute.
              </p>
            </Maui.Container.card>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Container.card>
    <p>This is a basic card with default styling.</p>
    </Maui.Container.card>

    <Maui.Container.card class="bg-blue-50 border-blue-200">
    <p>This card has custom styling.</p>
    </Maui.Container.card>|}
            />
          </div>
        </.example_card>
        
    <!-- Card with Header -->
        <.example_card
          title="Card with Header"
          description="Using card_header, card_title, and card_description for structured card headers."
        >
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Card Title</Maui.Container.card_title>
              <Maui.Container.card_description>
                This is a description that provides additional context about the card content.
              </Maui.Container.card_description>
            </Maui.Container.card_header>
          </Maui.Container.card>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Container.card>
    <Maui.Container.card_header>
    <Maui.Container.card_title>Card Title</Maui.Container.card_title>
    <Maui.Container.card_description>
      This is a description that provides additional context.
    </Maui.Container.card_description>
    </Maui.Container.card_header>
    </Maui.Container.card>|}
            />
          </div>
        </.example_card>
        
    <!-- Complete Card -->
        <.example_card
          title="Complete Card"
          description="A full card example with header, content, and footer sections."
        >
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>User Profile</Maui.Container.card_title>
              <Maui.Container.card_description>
                Manage your account settings and preferences.
              </Maui.Container.card_description>
            </Maui.Container.card_header>

            <Maui.Container.card_content>
              <div class="flex items-center gap-4">
                <div class="bg-zinc-100 dark:bg-zinc-800 rounded-full w-12 h-12 flex items-center justify-center">
                  <.icon name="hero-user" class="w-6 h-6 text-zinc-500 dark:text-zinc-400" />
                </div>
                <div>
                  <h4 class="font-medium text-zinc-900 dark:text-zinc-100">John Doe</h4>
                  <p class="text-sm text-zinc-500 dark:text-zinc-400">john@example.com</p>
                </div>
              </div>
              <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
                This card demonstrates how all card components work together to create a complete UI section with consistent styling.
              </p>
            </Maui.Container.card_content>

            <Maui.Container.card_footer class="gap-2">
              <.button variant="outline">Cancel</.button>
              <.button>Save Changes</.button>
            </Maui.Container.card_footer>
          </Maui.Container.card>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Container.card>
    <Maui.Container.card_header>
    <Maui.Container.card_title>User Profile</Maui.Container.card_title>
    <Maui.Container.card_description>
      Manage your account settings and preferences.
    </Maui.Container.card_description>
    </Maui.Container.card_header>

    <Maui.Container.card_content>
    <p>Your profile information goes here.</p>
    </Maui.Container.card_content>

    <Maui.Container.card_footer class="gap-2">
    <.button variant="outline">Cancel</.button>
    <.button>Save Changes</.button>
    </Maui.Container.card_footer>
    </Maui.Container.card>|}
            />
          </div>
        </.example_card>
        
    <!-- Card with Action -->
        <.example_card
          title="Card with Action"
          description="Using card_action to place action elements on the right side of the card header."
        >
          <Maui.Container.card>
            <Maui.Container.card_header>
              <Maui.Container.card_title>Notifications</Maui.Container.card_title>
              <Maui.Container.card_description>
                Configure how you receive notifications.
              </Maui.Container.card_description>
              <Maui.Container.card_action>
                <.button variant="outline" size="sm">
                  <.icon name="hero-cog-6-tooth" class="w-4 h-4 mr-1" /> Settings
                </.button>
              </Maui.Container.card_action>
            </Maui.Container.card_header>

            <Maui.Container.card_content>
              <div class="space-y-3">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <.icon name="hero-envelope" class="w-5 h-5 text-zinc-400" />
                    <span class="text-sm text-zinc-700 dark:text-zinc-300">Email Notifications</span>
                  </div>
                  <Maui.Components.badge variant="default">Enabled</Maui.Components.badge>
                </div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <.icon name="hero-bell" class="w-5 h-5 text-zinc-400" />
                    <span class="text-sm text-zinc-700 dark:text-zinc-300">Push Notifications</span>
                  </div>
                  <Maui.Components.badge variant="secondary">Disabled</Maui.Components.badge>
                </div>
              </div>
            </Maui.Container.card_content>
          </Maui.Container.card>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<Maui.Container.card>
    <Maui.Container.card_header>
    <Maui.Container.card_title>Notifications</Maui.Container.card_title>
    <Maui.Container.card_description>
      Configure how you receive notifications.
    </Maui.Container.card_description>
    <Maui.Container.card_action>
      <.button variant="outline" size="sm">Settings</.button>
    </Maui.Container.card_action>
    </Maui.Container.card_header>

    <Maui.Container.card_content>
    <p>Notification settings content here.</p>
    </Maui.Container.card_content>
    </Maui.Container.card>|}
            />
          </div>
        </.example_card>
        
    <!-- Multiple Cards Grid -->
        <.example_card
          title="Card Grid Layout"
          description="Cards work well in grid layouts for dashboards and data displays."
        >
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <Maui.Container.card class="border-l-4 border-l-green-500">
              <Maui.Container.card_header>
                <Maui.Container.card_title class="text-2xl">2,543</Maui.Container.card_title>
                <Maui.Container.card_description>Total Users</Maui.Container.card_description>
              </Maui.Container.card_header>
            </Maui.Container.card>

            <Maui.Container.card class="border-l-4 border-l-blue-500">
              <Maui.Container.card_header>
                <Maui.Container.card_title class="text-2xl">$12,450</Maui.Container.card_title>
                <Maui.Container.card_description>Revenue</Maui.Container.card_description>
              </Maui.Container.card_header>
            </Maui.Container.card>

            <Maui.Container.card class="border-l-4 border-l-purple-500">
              <Maui.Container.card_header>
                <Maui.Container.card_title class="text-2xl">98.5%</Maui.Container.card_title>
                <Maui.Container.card_description>Uptime</Maui.Container.card_description>
              </Maui.Container.card_header>
            </Maui.Container.card>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
    <Maui.Container.card class="border-l-4 border-l-green-500">
    <Maui.Container.card_header>
      <Maui.Container.card_title class="text-2xl">2,543</Maui.Container.card_title>
      <Maui.Container.card_description>Total Users</Maui.Container.card_description>
    </Maui.Container.card_header>
    </Maui.Container.card>
    ...
    </div>|}
            />
          </div>
        </.example_card>
        
    <!-- Props Table -->
        <div>
          <h2 class="text-xl font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Props</h2>
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <.props_table props={[
              %{name: "class", type: "string", default: "nil", description: "Additional CSS classes"},
              %{
                name: "rest",
                type: "global",
                default: "nil",
                description: "Arbitrary HTML attributes for card container"
              }
            ]} />
          </div>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
