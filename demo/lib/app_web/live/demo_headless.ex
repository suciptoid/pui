defmodule AppWeb.Live.DemoHeadless do
  @moduledoc """
  Interactive demo showcasing Maui's headless/unstyled component variants.

  Demonstrates the three usage levels:
  - Level 1: Low-level hooks (direct Floating UI access)
  - Level 2: Unstyled components (behavior without styles)
  - Level 3: Styled components (default Tailwind styling)
  """
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :unstyled_button_class,
        "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
      )
      |> assign(
        :unstyled_menu_class,
        "w-48 bg-white border border-gray-200 rounded shadow-lg py-1"
      )
      |> assign(
        :unstyled_menu_item_class,
        "px-4 py-2 hover:bg-gray-100 cursor-pointer flex items-center gap-2"
      )
      |> assign(:unstyled_dialog_class, "bg-white p-6 rounded-lg shadow-xl max-w-md w-full mx-4")
      |> assign(
        :unstyled_backdrop_class,
        "fixed inset-0 bg-black/50 flex items-center justify-center"
      )
      |> assign(:custom_css_framework, "tailwind")
      |> assign(:show_dialog, false)

    {:ok, socket}
  end

  def handle_event("update_class", %{"field" => field, "value" => value}, socket) do
    {:noreply, assign(socket, String.to_atom(field), value)}
  end

  def handle_event("select_framework", %{"framework" => framework}, socket) do
    socket =
      case framework do
        "tailwind" ->
          socket
          |> assign(:custom_css_framework, "tailwind")
          |> assign(
            :unstyled_button_class,
            "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          )
          |> assign(
            :unstyled_menu_class,
            "w-48 bg-white border border-gray-200 rounded shadow-lg py-1"
          )
          |> assign(
            :unstyled_menu_item_class,
            "px-4 py-2 hover:bg-gray-100 cursor-pointer flex items-center gap-2"
          )
          |> assign(
            :unstyled_dialog_class,
            "bg-white p-6 rounded-lg shadow-xl max-w-md w-full mx-4"
          )

        "bootstrap" ->
          socket
          |> assign(:custom_css_framework, "bootstrap")
          |> assign(:unstyled_button_class, "btn btn-primary")
          |> assign(:unstyled_menu_class, "dropdown-menu show")
          |> assign(:unstyled_menu_item_class, "dropdown-item d-flex align-items-center gap-2")
          |> assign(:unstyled_dialog_class, "modal-content p-4")

        "custom" ->
          socket
          |> assign(:custom_css_framework, "custom")

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("open_dialog", _params, socket) do
    {:noreply, assign(socket, :show_dialog, true)}
  end

  def handle_event("close_dialog", _params, socket) do
    {:noreply, assign(socket, :show_dialog, false)}
  end

  def handle_event("show_menu_action", %{"action" => action}, socket) do
    {:noreply, put_flash(socket, :info, "Menu action: #{action}")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={:headless}>
      <div id="overview" class="space-y-12">
        <%!-- Hero Section --%>
        <div class="text-center py-8">
          <div class="flex justify-center mb-4">
            <div class="p-4 rounded-2xl bg-primary/10">
              <.icon name="hero-paint-brush" class="size-16 text-primary" />
            </div>
          </div>
          <h1 class="text-4xl font-bold tracking-tight text-zinc-900 dark:text-zinc-100 sm:text-5xl mb-4">
            Headless Components
          </h1>
          <p class="text-xl text-muted-foreground max-w-3xl mx-auto">
            Maui supports three levels of component usage. Use low-level hooks, unstyled components,
            or fully styled defaults. Your choice, your styles.
          </p>
        </div>

        <%!-- Usage Levels Overview --%>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <.usage_level_card
            level="1"
            title="Low-level Hooks"
            description="Direct Floating UI access for maximum control. Build completely custom UIs."
            icon="hero-code-bracket"
            active={false}
          />
          <.usage_level_card
            level="2"
            title="Unstyled Components"
            description="Component behavior without default styles. Bring your own CSS."
            icon="hero-adjustments-horizontal"
            active={true}
          />
          <.usage_level_card
            level="3"
            title="Styled Components"
            description="Ready-to-use components with Tailwind CSS styling."
            icon="hero-sparkles"
            active={false}
          />
        </div>

        <%!-- CSS Framework Selector --%>
        <AppWeb.DocComponents.example_card
          title="CSS Framework Presets"
          description="Switch between different CSS framework presets to see how unstyled components adapt."
        >
          <div class="flex flex-wrap gap-3 mb-6">
            <.button
              variant={if @custom_css_framework == "tailwind", do: "default", else: "outline"}
              phx-click="select_framework"
              phx-value-framework="tailwind"
            >
              Tailwind CSS
            </.button>
            <.button
              variant={if @custom_css_framework == "bootstrap", do: "default", else: "outline"}
              phx-click="select_framework"
              phx-value-framework="bootstrap"
            >
              Bootstrap
            </.button>
            <.button
              variant={if @custom_css_framework == "custom", do: "default", else: "outline"}
              phx-click="select_framework"
              phx-value-framework="custom"
            >
              Custom
            </.button>
          </div>

          <p class="text-sm text-muted-foreground">
            Current framework:
            <span class="font-mono bg-muted px-2 py-0.5 rounded">{@custom_css_framework}</span>
          </p>
        </AppWeb.DocComponents.example_card>

        <%!-- Unstyled Button Demo --%>
        <AppWeb.DocComponents.example_card
          title="Unstyled Button"
          description="Use variant='unstyled' and provide your own classes."
        >
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="space-y-4">
              <div class="flex items-center gap-4">
                <.button variant="unstyled" class={@unstyled_button_class} phx-click="btn_click">
                  Custom Styled Button
                </.button>
              </div>

              <.input
                type="textarea"
                label="Button Classes"
                value={@unstyled_button_class}
                phx-change="update_class"
                phx-value-field="unstyled_button_class"
                id="button-class-input"
                rows={2}
              />
            </div>

            <AppWeb.DocComponents.code_block
              code={~S|<.button variant="unstyled" class="#{@unstyled_button_class}">
    Custom Styled Button
    </.button>|}
              language="heex"
            />
          </div>
        </AppWeb.DocComponents.example_card>

        <%!-- Unstyled Menu Demo --%>
        <AppWeb.DocComponents.example_card
          title="Unstyled Menu Button"
          description="Dropdown behavior with fully custom styling on trigger, menu, and items."
        >
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="space-y-4">
              <Maui.Dropdown.menu_button
                variant="unstyled"
                class={@unstyled_button_class}
                content_class={@unstyled_menu_class}
              >
                Open Custom Menu
                <:item
                  class={@unstyled_menu_item_class}
                  phx-click="show_menu_action"
                  phx-value-action="profile"
                >
                  <.icon name="hero-user" class="size-4" /> Profile
                </:item>
                <:item
                  class={@unstyled_menu_item_class}
                  phx-click="show_menu_action"
                  phx-value-action="settings"
                >
                  <.icon name="hero-cog" class="size-4" /> Settings
                </:item>
                <:item
                  class={@unstyled_menu_item_class}
                  phx-click="show_menu_action"
                  phx-value-action="logout"
                >
                  <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Logout
                </:item>
              </Maui.Dropdown.menu_button>

              <div class="space-y-2">
                <.input
                  type="text"
                  label="Menu Classes"
                  value={@unstyled_menu_class}
                  phx-change="update_class"
                  phx-value-field="unstyled_menu_class"
                  id="menu-class-input"
                />
                <.input
                  type="text"
                  label="Item Classes"
                  value={@unstyled_menu_item_class}
                  phx-change="update_class"
                  phx-value-field="unstyled_menu_item_class"
                  id="menu-item-class-input"
                />
              </div>
            </div>

            <AppWeb.DocComponents.code_block
              code={~S|<.menu_button
    variant="unstyled"
    class="#{@unstyled_button_class}"
    content_class="#{@unstyled_menu_class}"
    >
    Open Custom Menu
    <:item class="#{@unstyled_menu_item_class}">
    Profile
    </:item>
    </.menu_button>|}
              language="heex"
            />
          </div>
        </AppWeb.DocComponents.example_card>

        <%!-- Unstyled Dialog Demo --%>
        <AppWeb.DocComponents.example_card
          title="Unstyled Dialog"
          description="Modal dialog with custom styling for backdrop and content."
        >
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="space-y-4">
              <.button
                variant="unstyled"
                class={@unstyled_button_class}
                phx-click="open_dialog"
              >
                Open Custom Dialog
              </.button>

              <.dialog
                id="unstyled-dialog"
                variant="unstyled"
                class={@unstyled_backdrop_class}
                show={@show_dialog}
                on_cancel={JS.push("close_dialog")}
              >
                <:trigger :let={attr}>
                  <button {attr} class="hidden">Hidden Trigger</button>
                </:trigger>
                <div class={@unstyled_dialog_class}>
                  <h3 class="text-lg font-semibold mb-2">Custom Styled Dialog</h3>
                  <p class="text-muted-foreground mb-4">
                    This dialog uses the unstyled variant with custom classes for both the backdrop and content.
                  </p>
                  <div class="flex justify-end gap-2">
                    <.button
                      variant="unstyled"
                      class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded"
                      phx-click="close_dialog"
                    >
                      Cancel
                    </.button>
                    <.button
                      variant="unstyled"
                      class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                      phx-click="close_dialog"
                    >
                      Confirm
                    </.button>
                  </div>
                </div>
              </.dialog>

              <div class="space-y-2">
                <.input
                  type="text"
                  label="Backdrop Classes"
                  value={@unstyled_backdrop_class}
                  phx-change="update_class"
                  phx-value-field="unstyled_backdrop_class"
                  id="dialog-backdrop-class-input"
                />
                <.input
                  type="textarea"
                  label="Dialog Content Classes"
                  value={@unstyled_dialog_class}
                  phx-change="update_class"
                  phx-value-field="unstyled_dialog_class"
                  id="dialog-content-class-input"
                  rows={2}
                />
              </div>
            </div>

            <AppWeb.DocComponents.code_block
              code={~S|<.dialog
    id="my-dialog"
    variant="unstyled"
    class="#{@unstyled_backdrop_class}"
    show={@show_dialog}
    >
    <div class="#{@unstyled_dialog_class}">
    <h3>Custom Styled Dialog</h3>
    <p>Your content here...</p>
    </div>
    </.dialog>|}
              language="heex"
            />
          </div>
        </AppWeb.DocComponents.example_card>

        <%!-- Comparison Table --%>
        <AppWeb.DocComponents.example_card
          title="Feature Comparison"
          description="Compare the three usage levels to choose the right approach for your use case."
        >
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead>
                <tr class="border-b border-border">
                  <th class="text-left py-3 px-4 font-semibold">Feature</th>
                  <th class="text-center py-3 px-4 font-semibold">Low-level Hooks</th>
                  <th class="text-center py-3 px-4 font-semibold">Unstyled</th>
                  <th class="text-center py-3 px-4 font-semibold">Styled</th>
                </tr>
              </thead>
              <tbody>
                <tr class="border-b border-border/50">
                  <td class="py-3 px-4">Default Styling</td>
                  <td class="text-center py-3 px-4 text-red-500">✗</td>
                  <td class="text-center py-3 px-4 text-red-500">✗</td>
                  <td class="text-center py-3 px-4 text-green-500">✓</td>
                </tr>
                <tr class="border-b border-border/50">
                  <td class="py-3 px-4">ARIA Attributes</td>
                  <td class="text-center py-3 px-4 text-yellow-500">Manual</td>
                  <td class="text-center py-3 px-4 text-green-500">✓</td>
                  <td class="text-center py-3 px-4 text-green-500">✓</td>
                </tr>
                <tr class="border-b border-border/50">
                  <td class="py-3 px-4">Floating UI Integration</td>
                  <td class="text-center py-3 px-4 text-green-500">Direct</td>
                  <td class="text-center py-3 px-4 text-green-500">Built-in</td>
                  <td class="text-center py-3 px-4 text-green-500">Built-in</td>
                </tr>
                <tr class="border-b border-border/50">
                  <td class="py-3 px-4">Custom CSS</td>
                  <td class="text-center py-3 px-4 text-green-500">✓</td>
                  <td class="text-center py-3 px-4 text-green-500">✓</td>
                  <td class="text-center py-3 px-4 text-yellow-500">Override</td>
                </tr>
                <tr>
                  <td class="py-3 px-4">Best For</td>
                  <td class="text-center py-3 px-4 text-muted-foreground">Custom UIs</td>
                  <td class="text-center py-3 px-4 text-muted-foreground">Design Systems</td>
                  <td class="text-center py-3 px-4 text-muted-foreground">Rapid Prototyping</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AppWeb.DocComponents.example_card>

        <%!-- Code Examples --%>
        <AppWeb.DocComponents.example_card
          title="Code Examples"
          description="Example implementations for each usage level."
        >
          <div class="space-y-6">
            <div>
              <h4 class="font-semibold mb-2">Level 1: Low-level Hooks</h4>
              <AppWeb.DocComponents.code_block
                code={~S|<.popover_base phx-hook="Maui.Popover" data-placement="bottom">
    <button class="your-custom-classes">Trigger</button>
    <:popup class="your-popup-classes">
    Custom content
    </:popup>
    </.popover_base>|}
                language="heex"
              />
            </div>

            <div>
              <h4 class="font-semibold mb-2">Level 2: Unstyled Components</h4>
              <AppWeb.DocComponents.code_block
                code={~S|<.menu_button variant="unstyled" class="btn btn-primary">
    Open
    <:item class="dropdown-item">Profile</:item>
    <:item class="dropdown-item">Settings</:item>
    </.menu_button>|}
                language="heex"
              />
            </div>

            <div>
              <h4 class="font-semibold mb-2">Level 3: Styled Components</h4>
              <AppWeb.DocComponents.code_block
                code={~S|<.button variant="secondary" size="lg">
    Click me
    </.button>

    <.alert variant="destructive">
    <:title>Error</:title>
    <:description>Something went wrong.</:description>
    </.alert>|}
                language="heex"
              />
            </div>
          </div>
        </AppWeb.DocComponents.example_card>
      </div>
    </Layouts.docs>
    """
  end

  defp usage_level_card(assigns) do
    ~H"""
    <div class={[
      "p-6 rounded-lg border transition-colors",
      @active && "border-primary bg-primary/5",
      !@active && "border-border bg-card hover:bg-accent/50"
    ]}>
      <div class="flex items-center gap-3 mb-3">
        <div class={[
          "p-2 rounded-md",
          @active && "bg-primary/20",
          !@active && "bg-muted"
        ]}>
          <.icon
            name={@icon}
            class={[
              "size-5",
              @active && "text-primary",
              !@active && "text-muted-foreground"
            ]}
          />
        </div>
        <div>
          <span class="text-xs font-medium text-muted-foreground">Level {@level}</span>
          <h3 class="font-semibold">{@title}</h3>
        </div>
      </div>
      <p class="text-sm text-muted-foreground">{@description}</p>
    </div>
    """
  end
end
