defmodule AppWeb.Live.DemoPopover do
  use AppWeb, :live_view
  use PUI
  import AppWeb.DocComponents

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(counter: 1)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("click", _, socket) do
    {:noreply, socket |> assign(counter: socket.assigns.counter + 1)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="space-y-8">
        <!-- Page Header -->
        <div>
          <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">Popover & Tooltip</h1>
          <p class="mt-2 text-zinc-600 dark:text-zinc-400">
            Popover and tooltip components using Floating UI for precise positioning.
          </p>
        </div>
        
    <!-- Base Popover -->
        <.example_card
          title="Base Popover"
          description="Low-level popover building blocks using Floating UI for positioning."
        >
          <div class="flex flex-wrap gap-4">
            <.popover_base
              id="demo-popover-base"
              class="w-fit"
              phx-hook="PUI.Popover"
              data-placement="bottom"
            >
              <.button aria-label="Open popover example" aria-haspopup="menu">
                Open Popover
              </.button>

              <:popup class="aria-hidden:hidden block min-w-[250px] bg-popover text-popover-foreground rounded-md shadow-md border border-border p-4 z-50">
                <div class="space-y-2">
                  <p class="font-medium">Popover Content</p>
                  <p class="text-sm opacity-90">This is a popover with custom content.</p>
                  <.button size="sm" class="mt-2">
                    Action Button
                  </.button>
                </div>
              </:popup>
            </.popover_base>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<.popover_base
    id="demo-popover-base"
    class="w-fit"
    phx-hook="PUI.Popover"
    data-placement="bottom"
    >
    <.button aria-haspopup="menu">
    Open Popover
    </.button>

    <:popup class="aria-hidden:hidden block min-w-[250px] bg-popover text-popover-foreground rounded-md shadow-md border border-border p-4 z-50">
    <div class="space-y-2">
      <p class="font-medium">Popover Content</p>
      <p class="text-sm opacity-90">This is a popover with custom content.</p>
      <.button size="sm" class="mt-2">
        Action Button
      </.button>
    </div>
    </:popup>
    </.popover_base>|}
            />
          </div>
        </.example_card>
        
    <!-- Tooltip Variants -->
        <.example_card
          title="Tooltip Variants"
          description="Tooltips with different placements (top, bottom, left, right) and triggers."
        >
          <div class="flex flex-wrap gap-6 items-center justify-center">
            <.tooltip id="tooltip-left" placement="left">
              <.button variant="outline" size="icon" aria-label="Show left tooltip">
                <.icon name="hero-arrow-left" class="w-4 h-4" />
              </.button>
              <:tooltip>Tooltip on the left</:tooltip>
            </.tooltip>

            <.tooltip id="tooltip-top" placement="top">
              <.button variant="outline">
                Tooltip Top ({@counter})
              </.button>
              <:tooltip>
                Tooltip appears above the trigger. Counter: {@counter}
              </:tooltip>
            </.tooltip>

            <.tooltip id="tooltip-bottom" placement="bottom">
              <.button variant="outline" size="icon" aria-label="Show bottom tooltip">
                <.icon name="hero-arrow-down" class="w-4 h-4" />
              </.button>
              <:tooltip>Tooltip on the bottom</:tooltip>
            </.tooltip>

            <.tooltip id="tooltip-right" placement="right">
              <.button variant="outline" size="icon" aria-label="Show right tooltip">
                <.icon name="hero-arrow-right" class="w-4 h-4" />
              </.button>
              <:tooltip>Tooltip on the right</:tooltip>
            </.tooltip>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<.tooltip id="tooltip-left" placement="left">
    <.button variant="outline" size="icon">
    <.icon name="hero-arrow-left" class="w-4 h-4" />
    </.button>
    <:tooltip>Tooltip on the left</:tooltip>
    </.tooltip>

    <.tooltip id="tooltip-top" placement="top">
    <.button variant="outline">Tooltip Top</.button>
    <:tooltip>Tooltip appears above the trigger</:tooltip>
    </.tooltip>

    <.tooltip id="tooltip-bottom" placement="bottom">
    <.button variant="outline" size="icon">
    <.icon name="hero-arrow-down" class="w-4 h-4" />
    </.button>
    <:tooltip>Tooltip on the bottom</:tooltip>
    </.tooltip>

    <.tooltip id="tooltip-right" placement="right">
    <.button variant="outline" size="icon">
    <.icon name="hero-arrow-right" class="w-4 h-4" />
    </.button>
    <:tooltip>Tooltip on the right</:tooltip>
    </.tooltip>|}
            />
          </div>
        </.example_card>
        
    <!-- Tooltip with Icons -->
        <.example_card
          title="Tooltip with Icons"
          description="Tooltips triggered by icon buttons, useful for information hints."
        >
          <div class="flex flex-wrap gap-6 items-center">
            <div class="flex items-center gap-2">
              <span class="text-sm text-zinc-600 dark:text-zinc-400">Hover for info:</span>
              <.tooltip id="tooltip-info" placement="top">
                <button
                  type="button"
                  class="inline-flex cursor-help"
                  aria-label="More information"
                >
                  <.icon name="hero-information-circle" class="w-5 h-5 text-zinc-500" />
                </button>
                <:tooltip>
                  This provides additional context about the feature.
                </:tooltip>
              </.tooltip>
            </div>

            <div class="flex items-center gap-2">
              <span class="text-sm text-zinc-600 dark:text-zinc-400">Status:</span>
              <.tooltip id="tooltip-status" placement="bottom">
                <button
                  type="button"
                  class="flex items-center gap-1.5"
                  aria-label="Show system status details"
                >
                  <span class="w-2 h-2 rounded-full bg-green-500"></span>
                  <span class="text-sm">Active</span>
                </button>
                <:tooltip>
                  System is running normally with all services operational.
                </:tooltip>
              </.tooltip>
            </div>

            <div class="flex items-center gap-2">
              <span class="text-sm text-zinc-600 dark:text-zinc-400">Settings:</span>
              <.tooltip id="tooltip-settings" placement="top">
                <.button
                  variant="ghost"
                  size="icon"
                  class="h-8 w-8"
                  aria-label="Open settings tooltip"
                >
                  <.icon name="hero-cog-6-tooth" class="w-4 h-4" />
                </.button>
                <:tooltip>Configure settings</:tooltip>
              </.tooltip>
            </div>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<.tooltip id="tooltip-info" placement="top">
    <.icon name="hero-information-circle" class="w-5 h-5 text-zinc-500 cursor-help" />
    <:tooltip>This provides additional context about the feature.</:tooltip>
    </.tooltip>

    <.tooltip id="tooltip-status" placement="bottom">
    <span class="flex items-center gap-1.5">
    <span class="w-2 h-2 rounded-full bg-green-500"></span>
    <span class="text-sm">Active</span>
    </span>
    <:tooltip>System is running normally with all services operational.</:tooltip>
    </.tooltip>

    <.tooltip id="tooltip-settings" placement="top">
    <.button variant="ghost" size="icon" class="h-8 w-8">
    <.icon name="hero-cog-6-tooth" class="w-4 h-4" />
    </.button>
    <:tooltip>Configure settings</:tooltip>
    </.tooltip>|}
            />
          </div>
        </.example_card>
        
    <!-- Popover with Actions -->
        <.example_card
          title="Popover with Actions"
          description="Interactive popover with counter state that persists between interactions."
        >
          <div class="flex flex-wrap gap-4">
            <.popover_base
              id="demo-popover-action"
              class="w-fit"
              phx-hook="PUI.Popover"
              data-placement="bottom"
            >
              <.button variant="secondary" aria-haspopup="menu">
                Counter: {@counter}
              </.button>

              <:popup class="aria-hidden:hidden block min-w-[200px] bg-popover text-popover-foreground rounded-md shadow-md border border-border p-4 z-50">
                <div class="space-y-3">
                  <p class="font-medium">Interactive Popover</p>
                  <p class="text-sm text-zinc-600 dark:text-zinc-400">
                    Current count: <span class="font-bold">{@counter}</span>
                  </p>
                  <.button size="sm" phx-click="click" class="w-full">
                    Increment
                  </.button>
                </div>
              </:popup>
            </.popover_base>

            <.button variant="outline" phx-click="click">
              Also Increment ({@counter})
            </.button>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<.popover_base
    id="demo-popover-action"
    class="w-fit"
    phx-hook="PUI.Popover"
    data-placement="bottom"
    >
    <.button variant="secondary" aria-haspopup="menu">
    Counter: {@counter}
    </.button>

    <:popup class="aria-hidden:hidden block min-w-[200px] bg-popover text-popover-foreground rounded-md shadow-md border border-border p-4 z-50">
    <div class="space-y-3">
      <p class="font-medium">Interactive Popover</p>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Current count: <span class="font-bold">{@counter}</span>
      </p>
      <.button size="sm" phx-click="click" class="w-full">
        Increment
      </.button>
    </div>
    </:popup>
    </.popover_base>|}
            />
          </div>
        </.example_card>
        
    <!-- Rich Content Tooltip -->
        <.example_card
          title="Rich Content Tooltip"
          description="Tooltips can contain rich content like images and formatted text."
        >
          <div class="flex flex-wrap gap-4">
            <.tooltip id="tooltip-rich" placement="bottom" class="p-0! max-w-[200px]">
              <.button variant="outline">
                Hover for Preview
              </.button>
              <:tooltip>
                <div class="w-[200px]">
                  <div class="h-24 bg-gradient-to-br from-blue-400 to-purple-500 rounded-t-md flex items-center justify-center">
                    <.icon name="hero-photo" class="w-8 h-8 text-white/80" />
                  </div>
                  <div class="p-3">
                    <p class="font-medium text-sm">Rich Tooltip</p>
                    <p class="text-xs text-zinc-400 mt-1">
                      Tooltips can contain any HTML content including images and styled text.
                    </p>
                  </div>
                </div>
              </:tooltip>
            </.tooltip>
          </div>
          <div class="mt-4">
            <.code_block
              language="heex"
              code={~S|<.tooltip id="tooltip-rich" placement="bottom" class="p-0! max-w-[200px]">
    <.button variant="outline">Hover for Preview</.button>
    <:tooltip>
    <div class="w-[200px]">
      <div class="h-24 bg-gradient-to-br from-blue-400 to-purple-500 rounded-t-md">
        <!-- Content -->
      </div>
      <div class="p-3">
        <p class="font-medium text-sm">Rich Tooltip</p>
        <p class="text-xs text-zinc-400 mt-1">
          Tooltips can contain any HTML content.
        </p>
      </div>
    </div>
    </:tooltip>
    </.tooltip>|}
            />
          </div>
        </.example_card>
        
    <!-- Props Table -->
        <div>
          <h2 class="text-xl font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Props</h2>
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <.props_table props={[
              %{name: "id", type: "string", required: true, description: "Unique identifier"},
              %{
                name: "placement",
                type: "string",
                default: "top",
                description: "Tooltip position (top, bottom, left, right)"
              },
              %{name: "class", type: "string", default: "nil", description: "Additional CSS classes"},
              %{
                name: "phx-hook",
                type: "string",
                default: "PUI.Popover",
                description: "Phoenix hook for popover base"
              },
              %{
                name: "data-placement",
                type: "string",
                default: "top",
                description: "Popover placement attribute"
              }
            ]} />
          </div>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
