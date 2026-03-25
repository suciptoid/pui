defmodule AppWeb.Live.Demo do
  use AppWeb, :live_view
  use PUI

  def mount(_params, _session, socket) do
    form = to_form(%{"name" => "John Doe", "email" => "john@example.com", "text" => "text demo"})

    socket =
      socket
      |> assign(form: form)
      |> assign(:flash_placement, "top-center")
      |> assign(:playground_variant, "default")
      |> assign(:playground_size, "default")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("select_variant", %{"variant" => variant}, socket) do
    {:noreply, socket |> assign(:playground_variant, variant)}
  end

  def handle_event("select_size", %{"size" => size}, socket) do
    {:noreply, socket |> assign(:playground_size, size)}
  end

  def handle_event("btn_click", params, socket) do
    dbg({"btn click", params})
    {:noreply, socket}
  end

  def handle_event("send_flash", _params, socket) do
    PUI.Flash.send_flash("Hi, I'm a flash message from #{socket.id}")
    assigns = %{}

    PUI.Flash.send_flash(~H"""
    <div class="flex flex-col">
      <span>Hello world</span>
      <.button size="sm">click me</.button>
    </div>
    """)

    {:noreply, socket}
  end

  def handle_event("custom_flash", _params, socket) do
    assigns = %{}

    message = ~H"""
    <div class="flex items-center gap-2">
      <div>
        <.icon name="hero-check-circle" class="size-6" /> Flash customized successfully!
      </div>
      <button
        data-close
        class=" hidden group-hover:flex top-1.5 right-1.5 p-0.5 w-fit items-center justify-center rounded-sm hover:bg-popover/90"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    """

    PUI.Flash.send_flash(%PUI.Flash.Message{
      type: :info,
      message: message,
      duration: 8,
      show_close: false,
      class: "w-fit! border-green-500! bg-green-100! text-green-800!"
    })
    |> dbg

    {:noreply, socket}
  end

  def handle_event("update_flash", _prams, socket) do
    assigns = %{}

    message = ~H"""
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
        class="animate-spin text-blue-500"
      >
        <path stroke="none" d="M0 0h24v24H0z" fill="none" /><path d="M12 6l0 -3" /><path d="M16.25 7.75l2.15 -2.15" /><path d="M18 12l3 0" /><path d="M16.25 16.25l2.15 2.15" /><path d="M12 18l0 3" /><path d="M7.75 16.25l-2.15 2.15" /><path d="M6 12l-3 0" /><path d="M7.75 7.75l-2.15 -2.15" />
      </svg>
      Updating...
    </div>
    """

    PUI.Flash.send_flash(%PUI.Flash.Message{
      id: "update-me",
      type: :info,
      message: message,
      duration: -1
    })

    Process.send_after(self(), :update_flash, 10000)
    {:noreply, socket}
  end

  def handle_event("set_flash_placement", %{"placement" => placement}, socket) do
    {:noreply, socket |> assign(:flash_placement, placement)}
  end

  def handle_event("put_flash", _params, socket) do
    flash_id = "#{System.unique_integer([:positive])}"

    message =
      [
        "Short message.",
        "A bit longer message that spans two lines.",
        "This is a longer description that intentionally takes more vertical space to demonstrate stacking with varying heights.",
        "An even longer description that should span multiple lines so we can verify the clamped collapsed height and smooth expansion animation when hovering or focusing the viewport."
      ]
      |> Enum.random()

    {:noreply,
     socket
     |> put_flash(
       "info-#{flash_id}",
       {:info, message}
     )
     |> push_patch(to: "/flash")}
  end

  def handle_event("put_basic_flash", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Flash message with type :info"
     )
     |> push_patch(to: "/flash")}
  end

  def handle_event("put_redirect_flash", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Flash message navigating to dead view with type :info"
     )
     |> put_flash(
       :error,
       "Flash message navigating to dead view with type :error"
     )
     |> push_navigate(to: "/lc")}
  end

  def handle_event("validate", params, socket) do
    socket = socket |> assign(:form, to_form(params))
    {:noreply, socket}
  end

  def handle_info(:update_flash, socket) do
    assigns = %{}

    message = ~H"""
    <div class="flex items-start gap-2">
      <.icon name="hero-check-circle" class="size-5" /> Flash updated from backend
    </div>
    """

    PUI.Flash.send_flash(%PUI.Flash.Message{
      id: "update-me",
      type: :info,
      duration: 5,
      message: message
    })

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <PUI.Flash.flash_group
        flash={@flash}
        position={@flash_placement}
        live={true}
      />
      <.demo_overview :if={@live_action == :index} />
      <.demo_inputs :if={@live_action == :inputs} form={@form} />
      <.demo_buttons
        :if={@live_action == :buttons}
        variant={@playground_variant}
        size={@playground_size}
      />
      <.demo_dropdown :if={@live_action == :dropdown} />
      <.demo_popover :if={@live_action == :popover} />
      <.demo_toast :if={@live_action == :toast} />
      <.demo_alert :if={@live_action == :alert} />
    </Layouts.docs>
    """
  end

  def demo_alert(assigns) do
    ~H"""
    <div class="space-y-8">
      <!-- Alert without Description -->
      <AppWeb.DocComponents.example_card
        title="Alert without Description"
        description="A compact alert with just a title and icon. Useful for brief status updates."
      >
        <div class="space-y-4">
          <PUI.Alert.alert>
            <:icon>
              <.icon name="hero-check-circle" class="size-5" />
            </:icon>
            <:title>Your changes have been saved</:title>
          </PUI.Alert.alert>
          <AppWeb.DocComponents.code_block
            code={"<.alert>\n  <:icon>\n    <.icon name=\"hero-check-circle\" class=\"size-5\" />\n  </:icon>\n  <:title>Your changes have been saved</:title>\n</.alert>"}
            language="heex"
          />
        </div>
      </AppWeb.DocComponents.example_card>
      
    <!-- Alert with Title and Description -->
      <AppWeb.DocComponents.example_card
        title="Alert with Title and Description"
        description="Use both title and description slots for more detailed alert messages."
      >
        <div class="space-y-4">
          <PUI.Alert.alert>
            <:icon>
              <.icon name="hero-information-circle" class="size-5" />
            </:icon>
            <:title>Update Available</:title>
            <:description>
              A new version of the application is available. Update now to get the latest features and improvements.
            </:description>
          </PUI.Alert.alert>
          <AppWeb.DocComponents.code_block
            code={"<.alert>\n  <:icon>\n    <.icon name=\"hero-information-circle\" class=\"size-5\" />\n  </:icon>\n  <:title>Update Available</:title>\n  <:description>\n    A new version of the application is available.\n  </:description>\n</.alert>"}
            language="heex"
          />
        </div>
      </AppWeb.DocComponents.example_card>
      
    <!-- Destructive Alert Variant -->
      <AppWeb.DocComponents.example_card
        title="Destructive Alert Variant"
        description="Use the destructive variant for errors, warnings, or destructive actions."
      >
        <div class="space-y-4">
          <PUI.Alert.alert variant="destructive">
            <:icon>
              <.icon name="hero-exclamation-triangle" class="size-5" />
            </:icon>
            <:title>Error</:title>
            <:description>
              Unable to process your request. Please check your connection and try again.
            </:description>
          </PUI.Alert.alert>
          <AppWeb.DocComponents.code_block
            code={"<.alert variant=\"destructive\">\n  <:icon>\n    <.icon name=\"hero-exclamation-triangle\" class=\"size-5\" />\n  </:icon>\n  <:title>Error</:title>\n  <:description>\n    Unable to process your request.\n  </:description>\n</.alert>"}
            language="heex"
          />
        </div>
      </AppWeb.DocComponents.example_card>
      
    <!-- Alert with Custom Icon -->
      <AppWeb.DocComponents.example_card
        title="Alert with Custom Icon"
        description="Use any icon or SVG in the icon slot to customize the alert's visual appearance."
      >
        <div class="space-y-4">
          <PUI.Alert.alert>
            <:icon>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-5"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m3.75 2.383a14.406 14.406 0 0 1-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 1 0-7.517 0c.85.493 1.509 1.333 1.509 2.316V18"
                />
              </svg>
            </:icon>
            <:title>Tips & Tricks</:title>
            <:description>
              Customize your alert icons using Heroicons, Lucide, or any custom SVG.
            </:description>
          </PUI.Alert.alert>
          <AppWeb.DocComponents.code_block
            code={"<.alert>\n  <:icon>\n    <svg xmlns=\"http://www.w3.org/2000/svg\" class=\"size-5\" viewBox=\"0 0 24 24\">\n      <!-- Custom SVG icon -->\n    </svg>\n  </:icon>\n  <:title>Tips & Tricks</:title>\n</.alert>"}
            language="heex"
          />
        </div>
      </AppWeb.DocComponents.example_card>
      
    <!-- Props Table -->
      <AppWeb.DocComponents.example_card
        title="Component API"
        description="Available attributes and slots for the alert component."
      >
        <AppWeb.DocComponents.props_table props={[
          %{
            name: "variant",
            type: "string",
            default: "\"default\"",
            description: "Alert style variant: default, destructive"
          },
          %{name: "class", type: "string", default: "\"\"", description: "Additional CSS classes"},
          %{
            name: "icon",
            type: "slot",
            default: "nil",
            description: "Optional icon displayed at the start"
          },
          %{name: "title", type: "slot", default: "nil", description: "Alert title text"},
          %{
            name: "description",
            type: "slot",
            default: "nil",
            description: "Detailed description text"
          }
        ]} />
      </AppWeb.DocComponents.example_card>
    </div>
    """
  end

  defp demo_overview(assigns) do
    ~H"""
    <div class="space-y-10">
      <%!-- Hero Section --%>
      <div class="text-center py-8">
        <div class="flex justify-center mb-4">
          <div class="p-4 rounded-2xl bg-primary/10">
            <.icon name="hero-swatch" class="size-16 text-primary" />
          </div>
        </div>
        <h1 class="text-4xl font-bold tracking-tight text-zinc-900 dark:text-zinc-100 sm:text-5xl mb-4">
          PUI UI Components
        </h1>
        <p class="text-xl text-muted-foreground max-w-2xl mx-auto">
          A comprehensive collection of Phoenix LiveView components built with Tailwind CSS.
          Beautiful, accessible, and fully customizable.
        </p>
        <div class="mt-6 flex justify-center gap-4">
          <.button patch={~p"/inputs"} size="lg">
            <.icon name="hero-rocket-launch" class="size-5 mr-2" /> Get Started
          </.button>
          <.button variant="outline" size="lg" href="https://github.com">
            <.icon name="hero-code-bracket" class="size-5 mr-2" /> View on GitHub
          </.button>
        </div>
      </div>

      <%!-- Installation Section --%>
      <AppWeb.DocComponents.example_card
        title="Installation"
        description="Add PUI to your Phoenix LiveView project in just a few steps."
      >
        <div class="space-y-4">
          <div>
            <h4 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-2">
              1. Add the dependency to your mix.exs
            </h4>
            <AppWeb.DocComponents.code_block
              code={"def deps do\n  [\n    {:pui, github: \"your-org/pui\"}\n  ]\nend"}
              language="elixir"
            />
          </div>
          <div>
            <h4 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-2">
              2. Run mix deps.get
            </h4>
            <AppWeb.DocComponents.code_block
              code="mix deps.get"
              language="bash"
            />
          </div>
        </div>
      </AppWeb.DocComponents.example_card>

      <%!-- Quick Start Section --%>
      <AppWeb.DocComponents.example_card
        title="Quick Start"
        description="Import all components with a single line of code."
      >
        <div class="space-y-4">
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Add
            <code class="px-1.5 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">use PUI</code>
            to your LiveView module
            to import all components automatically.
          </p>
          <AppWeb.DocComponents.code_block
            code={"defmodule MyAppWeb.MyLive do\n  use MyAppWeb, :live_view\n  use PUI\n\n  def render(assigns) do\n    ~H\"\"\"\n    <.button>Click me</.button>\n    <.input label=\"Name\" />\n    \"\"\"\n  end\nend"}
            language="elixir"
          />
        </div>
      </AppWeb.DocComponents.example_card>

      <%!-- Component Cards Grid --%>
      <div>
        <h2 class="text-2xl font-bold text-zinc-900 dark:text-zinc-100 mb-6">Components</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <.component_card
            title="Inputs"
            description="Text inputs, checkboxes, radio buttons, switches, and more."
            icon="hero-cursor-arrow-rays"
            patch={~p"/inputs"}
          />
          <.component_card
            title="Select"
            description="Single and multi-select dropdowns with search support."
            icon="hero-chevron-up-down"
            patch={~p"/select"}
          />
          <.component_card
            title="Buttons"
            description="Various button styles, sizes, and variants for your application."
            icon="hero-cursor-arrow-ripple"
            patch={~p"/buttons"}
          />
          <.component_card
            title="Dropdown"
            description="Dropdown menus with items, separators, and shortcuts."
            icon="hero-chevron-down"
            patch={~p"/dropdown"}
          />
          <.component_card
            title="Dialog"
            description="Modal dialogs for confirmations and complex interactions."
            icon="hero-window"
            patch={~p"/dialog"}
          />
          <.component_card
            title="Popover"
            description="Floating UI popovers for contextual information."
            icon="hero-chat-bubble-left"
            patch={~p"/popover"}
          />
          <.component_card
            title="Alert"
            description="Alert components for important messages and warnings."
            icon="hero-exclamation-triangle"
            patch={~p"/alert"}
          />
          <.component_card
            title="Toast"
            description="Toast notifications with beautiful animations."
            icon="hero-bell"
            patch={~p"/toast"}
          />
          <.component_card
            title="Container"
            description="Layout containers for structuring your UI."
            icon="hero-square-2-stack"
            patch={~p"/container"}
          />
          <.component_card
            title="Tabs"
            description="Tab navigation for organizing content into sections."
            icon="hero-rectangle-stack"
            patch={~p"/tab"}
          />
          <.component_card
            title="Progress & Badges"
            description="Progress bars and badge components for status indicators."
            icon="hero-bolt"
            patch={~p"/progress-badges"}
          />
          <.component_card
            title="Headless Components"
            description="Unstyled components with custom CSS framework support."
            icon="hero-paint-brush"
            patch={~p"/headless"}
          />
        </div>
      </div>

      <%!-- Features Section --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="p-6 rounded-lg border border-border bg-card">
          <div class="p-2 rounded-md bg-primary/10 w-fit mb-3">
            <.icon name="hero-bolt" class="size-6 text-primary" />
          </div>
          <h3 class="font-semibold text-lg mb-2">Built for LiveView</h3>
          <p class="text-sm text-muted-foreground">
            Native Phoenix LiveView components with real-time updates and minimal JavaScript.
          </p>
        </div>
        <div class="p-6 rounded-lg border border-border bg-card">
          <div class="p-2 rounded-md bg-primary/10 w-fit mb-3">
            <.icon name="hero-paint-brush" class="size-6 text-primary" />
          </div>
          <h3 class="font-semibold text-lg mb-2">Tailwind CSS</h3>
          <p class="text-sm text-muted-foreground">
            Styled with Tailwind CSS for easy customization and theming support.
          </p>
        </div>
        <div class="p-6 rounded-lg border border-border bg-card">
          <div class="p-2 rounded-md bg-primary/10 w-fit mb-3">
            <.icon name="hero-check-badge" class="size-6 text-primary" />
          </div>
          <h3 class="font-semibold text-lg mb-2">Accessible</h3>
          <p class="text-sm text-muted-foreground">
            ARIA-compliant components with keyboard navigation and screen reader support.
          </p>
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :patch, :string, required: true

  defp component_card(assigns) do
    ~H"""
    <.link
      patch={@patch}
      class="block p-6 rounded-lg border border-border bg-card hover:bg-accent/50 transition-colors group"
    >
      <div class="flex items-start gap-4">
        <div class="p-2 rounded-md bg-primary/10 group-hover:bg-primary/20 transition-colors">
          <.icon name={@icon} class="size-6 text-primary" />
        </div>
        <div class="flex-1">
          <h3 class="font-semibold text-lg mb-1">{@title}</h3>
          <p class="text-sm text-muted-foreground">{@description}</p>
        </div>
      </div>
    </.link>
    """
  end

  defp demo_popover(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h2 class="text-lg font-semibold mb-4">Base Popover</h2>
        <p class="text-muted-foreground">
          Popover components that use Floating UI for positioning.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <.popover_base
          id="demo-popover-base"
          class="w-fit"
          phx-hook="PUI.Popover"
          data-placement="top"
        >
          <.button aria-haspopup="menu">
            Click Me
          </.button>

          <:popup class="aria-hidden:hidden block min-w-[250px] bg-foreground text-primary-foreground rounded-md shadow-md border border-base-300 p-4">
            <div class="space-y-2">
              <p class="font-medium">Popover Content</p>
              <p class="text-sm opacity-90">This is a popover with custom content.</p>
              <.button aria-haspopup="menu" role="combobox" size="sm">
                Action Button
              </.button>
            </div>
          </:popup>
        </.popover_base>
      </div>
    </div>
    """
  end

  defp demo_inputs(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-lg font-semibold mb-4">Text Inputs</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.input id="input-text" type="text" placeholder="Enter text" label="Input Text" />
          <.input
            id="input-password"
            type="password"
            placeholder="Enter password"
            label="Input Password"
            data-bwignore
          />
          <.input id="input-file" type="file" placeholder="Enter password" label="Input File" />

          <.input
            id="input-disabled"
            type="text"
            disabled
            placeholder="Enter text"
            label="Input Disabled"
          />
          <div class="grid w-full max-w-sm items-center gap-3">
            <.label for="email">Field with custom label</.label>
            <.input type="email" id="email" placeholder="you@company.com" data-bwignore />
          </div>

          <div class="flex justify-end flex-col">
            <p class="text-xs text-gray-400 p-1">Without label</p>
            <.input type="text" placeholder="Enter text" id="custom-id" />
          </div>
          <div class="flex justify-end flex-col">
            <.form :let={f} id="form-demo" for={@form} phx-change="validate">
              <.input
                field={f[:name]}
                placeholder="Enter your name"
                label="With Phoenix Form"
              />

              <span class="text-gray-400 text-sm">
                Your Input: {f[:name].value}
              </span>
            </.form>
          </div>
          <div class="flex justify-end flex-col">
            <.textarea
              label="Textarea"
              placeholder="Enter text..."
              field={@form[:text]}
              id="custom-textarea"
            />
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Checkboxes</h2>
        <div class="space-y-4">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <.checkbox :for={cb <- [1, 2, 3, 4]} id={"demo-checkbox-#{cb}"} label={"Checkbox #{cb}"} />
          </div>

          <.checkbox id="demo-checkbox-label" label="Agree to terms and conditions" />

          <div class="flex items-start gap-3">
            <.checkbox id="terms-2" checked />
            <div class="grid gap-2">
              <.label for="terms-2">Accept terms and conditions</.label>
              <p class="text-muted-foreground text-sm">
                By clicking this checkbox, you agree to the terms and conditions.
              </p>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <.checkbox id="toggle" class="peer" disabled />
            <.label for="toggle">Enable notifications</.label>
          </div>

          <.label class="hover:bg-accent/50 flex items-start gap-3 rounded-lg border border-border p-3 has-checked:border-blue-600 has-checked:bg-blue-50 dark:has-checked:border-blue-900 dark:has-checked:bg-blue-950">
            <.checkbox
              id="toggle-2"
              class="checked:border-blue-600! checked:bg-blue-600! checked:text-white dark:checked:border-blue-700 dark:checked:bg-blue-700"
            />
            <div class="grid gap-1.5 font-normal">
              <p class="text-sm leading-none font-medium">
                Enable notifications
              </p>
              <p class="text-muted-foreground text-sm">
                You can enable or disable notifications at any time.
              </p>
            </div>
          </.label>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Radio Buttons</h2>
        <div role="radiogroup" class="grid gap-3">
          <div class="flex items-center gap-3">
            <.label class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50">
              <.radio name="radio-1" value="compact" /> Compact
            </.label>
            <.label class="flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50">
              <.radio name="radio-1" value="default" /> Default
            </.label>
          </div>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">Switches</h2>
        <div class="flex flex-col gap-4">
          <.switch name="switch-1" id="switch-1" class="peer" />
          <.switch id="switch-2" label="Airplane Mode" />
        </div>
      </div>
    </div>
    """
  end

  attr :variant, :string, default: "default"
  attr :size, :string, default: "default"

  defp demo_buttons(assigns) do
    ~H"""
    <div class="space-y-8">
      <!-- Interactive Playground -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Interactive Playground</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Customize the button below and see the generated code update in real-time.
        </p>

        <AppWeb.DocComponents.playground_controls
          id="button-playground"
          variants={["default", "secondary", "destructive", "outline", "ghost", "link"]}
          sizes={["sm", "default", "lg"]}
          selected_variant={@variant}
          selected_size={@size}
        />

        <div class="mt-4 grid grid-cols-1 lg:grid-cols-2 gap-4">
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 bg-zinc-50 dark:bg-zinc-800/50">
            <div class="flex items-center justify-center min-h-[100px]">
              <.button id="button-preview" variant={@variant} size={@size} phx-click="btn_click">
                Button Preview
              </.button>
            </div>
          </div>
          <AppWeb.DocComponents.code_block code={button_code(@variant, @size)} language="heex" />
        </div>
      </div>
      
    <!-- All Variants -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Variants</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Buttons come in 6 different variants to suit various use cases.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap gap-3">
            <.button
              :for={variant <- ["default", "secondary", "destructive", "outline", "ghost", "link"]}
              variant={variant}
              phx-click="btn_click"
            >
              {String.capitalize(variant)}
            </.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button variant=\"default\">Default</.button>\n<.button variant=\"secondary\">Secondary</.button>\n<.button variant=\"destructive\">Destructive</.button>\n<.button variant=\"outline\">Outline</.button>\n<.button variant=\"ghost\">Ghost</.button>\n<.button variant=\"link\">Link</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- Sizes -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Sizes</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Three sizes are available: small, default, and large.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap items-center gap-3">
            <.button size="sm" phx-click="btn_click">Small</.button>
            <.button size="default" phx-click="btn_click">Default</.button>
            <.button size="lg" phx-click="btn_click">Large</.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button size=\"sm\">Small</.button>\n<.button size=\"default\">Default</.button>\n<.button size=\"lg\">Large</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- Icon Buttons -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Icon Buttons</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Use the
          <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">size="icon"</code>
          attribute for square icon buttons.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap gap-3">
            <.button
              :for={variant <- ["default", "secondary", "destructive", "outline", "ghost"]}
              variant={variant}
              size="icon"
              aria-label={"#{variant} favorite button"}
              phx-click="btn_click"
            >
              <.icon name="hero-heart" class="w-4 h-4" />
            </.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button variant=\"default\" size=\"icon\">\n  <.icon name=\"hero-heart\" class=\"w-4 h-4\" />\n</.button>\n\n<.button variant=\"outline\" size=\"icon\">\n  <.icon name=\"hero-cog\" class=\"w-4 h-4\" />\n</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- Buttons with Icons -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Buttons with Icons</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Add icons alongside text for enhanced visual context.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap gap-3">
            <.button phx-click="btn_click">
              <.icon name="hero-heart" class="w-4 h-4" /> Like
            </.button>
            <.button variant="secondary" phx-click="btn_click">
              <.icon name="hero-arrow-path" class="w-4 h-4" /> Refresh
            </.button>
            <.button variant="destructive" phx-click="btn_click">
              <.icon name="hero-trash" class="w-4 h-4" /> Delete
            </.button>
            <.button variant="outline" phx-click="btn_click">
              <.icon name="hero-arrow-down-tray" class="w-4 h-4" /> Download
            </.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button>\n  <.icon name=\"hero-heart\" class=\"w-4 h-4\" /> Like\n</.button>\n\n<.button variant=\"destructive\">\n  <.icon name=\"hero-trash\" class=\"w-4 h-4\" /> Delete\n</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- Buttons as Links -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Buttons as Links</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Buttons can act as links using <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">navigate</code>, <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">patch</code>, or <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">href</code>.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap gap-3">
            <.button variant="link" patch={~p"/buttons"}>
              Patch Navigation
            </.button>

            <.button variant="outline" navigate={~p"/buttons"}>
              Navigate Link
            </.button>

            <.button variant="secondary" href="/lc">
              Href Link
            </.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button variant=\"link\" patch={~p\"/settings\"}>\n  Patch Navigation\n</.button>\n\n<.button variant=\"outline\" navigate={~p\"/profile\"}>\n  Navigate Link\n</.button>\n\n<.button variant=\"secondary\" href=\"/logout\">\n  Href Link\n</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- Disabled State -->
      <div>
        <h2 class="text-lg font-semibold mb-4">Disabled State</h2>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm mb-4">
          Use the
          <code class="px-1 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded text-sm">disabled</code>
          attribute to disable buttons.
        </p>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 space-y-6">
          <div class="flex flex-wrap gap-3">
            <.button disabled phx-click="btn_click">Disabled</.button>
            <.button variant="secondary" disabled phx-click="btn_click">Disabled</.button>
            <.button variant="destructive" disabled phx-click="btn_click">Disabled</.button>
            <.button variant="outline" disabled phx-click="btn_click">Disabled</.button>
          </div>
          <AppWeb.DocComponents.code_block
            code={"<.button disabled>Disabled</.button>\n<.button variant=\"secondary\" disabled>Disabled</.button>"}
            language="heex"
          />
        </div>
      </div>
      
    <!-- API Section -->
      <AppWeb.DocComponents.component_api_section
        module="PUI.Button"
        function="button"
        import_statement="use PUI"
        props={[
          %{
            name: "variant",
            type: "string",
            default: "\"default\"",
            description: "Button style variant: default, secondary, destructive, outline, ghost, link"
          },
          %{
            name: "size",
            type: "string",
            default: "\"default\"",
            description: "Button size: sm, default, lg, icon"
          },
          %{name: "class", type: "string", default: "\"\"", description: "Additional CSS classes"},
          %{name: "disabled", type: "boolean", default: "false", description: "Disable the button"},
          %{
            name: "navigate",
            type: "string",
            default: "nil",
            description: "Phoenix LiveView navigate path"
          },
          %{
            name: "patch",
            type: "string",
            default: "nil",
            description: "Phoenix LiveView patch path"
          },
          %{name: "href", type: "string", default: "nil", description: "Standard href link"}
        ]}
      >
        <:description>
          A versatile button component with multiple variants and sizes. Supports icons,
          link behavior, and follows Phoenix LiveView conventions.
        </:description>
      </AppWeb.DocComponents.component_api_section>
    </div>
    """
  end

  defp button_code(variant, size) do
    ~s|<.button variant="#{variant}" size="#{size}">
  Button
</.button>|
  end

  defp demo_dropdown(assigns) do
    ~H"""
    <div class="space-y-8">
      <!-- Menu Button with Items -->
      <AppWeb.DocComponents.example_card
        title="Menu Button with Items"
        description="Basic dropdown with labeled items and icons. Use the <:item> slot for simple menu options."
      >
        <div class="flex flex-wrap gap-4 mb-6">
          <PUI.Dropdown.menu_button id="dropdown-account" content_class="w-52">
            <.icon name="hero-user" class="size-4" /> Account
            <:item navigate="/select">
              <.icon name="hero-user" class="size-4" /> Profile
            </:item>
            <:item>
              <.icon name="hero-cog" class="size-4" /> Settings
            </:item>
            <:item>
              <.icon name="hero-question-mark-circle" class="size-4" /> Help
            </:item>
          </PUI.Dropdown.menu_button>
        </div>
        <AppWeb.DocComponents.code_block
          code={~s|<.menu_button content_class="w-52">
    <.icon name="hero-user" class="size-4" /> Account
    <:item navigate="/profile">Profile</:item>
    <:item>Settings</:item>
    <:item>Help</:item>
    </.menu_button>|}
          language="heex"
        />
      </AppWeb.DocComponents.example_card>
      
    <!-- Menu with Keyboard Shortcuts -->
      <AppWeb.DocComponents.example_card
        title="Menu with Keyboard Shortcuts"
        description="Display keyboard shortcuts for quick actions. Add the shortcut attribute to items."
      >
        <div class="flex flex-wrap gap-4 mb-6">
          <PUI.Dropdown.menu_button id="dropdown-shortcuts" content_class="w-56">
            <.icon name="hero-command-line" class="size-4" /> Actions
            <:item shortcut="⌘P">
              <.icon name="hero-document" class="size-4" /> Print
            </:item>
            <:item shortcut="⌘S">
              <.icon name="hero-arrow-down-tray" class="size-4" /> Save
            </:item>
            <:item shortcut="⇧⌘N">
              <.icon name="hero-document-plus" class="size-4" /> New File
            </:item>
            <:item shortcut="⌘Q">
              <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Quit
            </:item>
          </PUI.Dropdown.menu_button>
        </div>
        <AppWeb.DocComponents.code_block
          code={~s|<.menu_button content_class="w-56">
    Actions
    <:item shortcut="⌘P">Print</:item>
    <:item shortcut="⌘S">Save</:item>
    <:item shortcut="⇧⌘N">New File</:item>
    <:item shortcut="⌘Q">Quit</:item>
    </.menu_button>|}
          language="heex"
        />
      </AppWeb.DocComponents.example_card>
      
    <!-- Destructive Action Items -->
      <AppWeb.DocComponents.example_card
        title="Destructive Action Items"
        description="Use the destructive variant for actions that delete or remove data. These items appear with warning colors."
      >
        <div class="flex flex-wrap gap-4 mb-6">
          <PUI.Dropdown.menu_button id="dropdown-destructive" content_class="w-56" variant="outline">
            <.icon name="hero-trash" class="size-4" /> Delete Options
            <:item variant="destructive" shortcut="⌘⌫">
              <.icon name="hero-trash" class="size-4" /> Delete File
            </:item>
            <:item variant="destructive">
              <.icon name="hero-folder-minus" class="size-4" /> Remove Folder
            </:item>
            <:item variant="destructive">
              <.icon name="hero-user-minus" class="size-4" /> Remove User
            </:item>
          </PUI.Dropdown.menu_button>
        </div>
        <AppWeb.DocComponents.code_block
          code={~s|<.menu_button content_class="w-56" variant="outline">
    Delete Options
    <:item variant="destructive" shortcut="⌘⌫">
    Delete File
    </:item>
    <:item variant="destructive">
    Remove Folder
    </:item>
    </.menu_button>|}
          language="heex"
        />
      </AppWeb.DocComponents.example_card>
      
    <!-- Menu Separators -->
      <AppWeb.DocComponents.example_card
        title="Menu Separators"
        description="Group related items with separators using the <:items> slot and menu_separator component."
      >
        <div class="flex flex-wrap gap-4 mb-6">
          <PUI.Dropdown.menu_button id="dropdown-separators" content_class="w-56">
            <.icon name="hero-bars-3" class="size-4" /> More Options
            <:items>
              <PUI.Dropdown.menu_item>
                <.icon name="hero-eye" class="size-4" /> View Details
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_item>
                <.icon name="hero-pencil" class="size-4" /> Edit
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_separator />
              <PUI.Dropdown.menu_item>
                <.icon name="hero-share" class="size-4" /> Share
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_item>
                <.icon name="hero-link" class="size-4" /> Copy Link
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_separator />
              <PUI.Dropdown.menu_item variant="destructive">
                <.icon name="hero-trash" class="size-4" /> Delete
              </PUI.Dropdown.menu_item>
            </:items>
          </PUI.Dropdown.menu_button>
        </div>
        <AppWeb.DocComponents.code_block
          code={~s|<.menu_button content_class="w-56">
    More Options
    <:items>
    <.menu_item>View Details</.menu_item>
    <.menu_item>Edit</.menu_item>
    <.menu_separator />
    <.menu_item>Share</.menu_item>
    <.menu_item>Copy Link</.menu_item>
    <.menu_separator />
    <.menu_item variant="destructive">Delete</.menu_item>
    </:items>
    </.menu_button>|}
          language="heex"
        />
      </AppWeb.DocComponents.example_card>
      
    <!-- Custom Items Slot with Undo Handler -->
      <AppWeb.DocComponents.example_card
        title="Custom Items with Event Handlers"
        description="Use the <:items> slot for full control over menu items. Supports phx-click handlers like the undo action below."
      >
        <div class="flex flex-wrap gap-4 mb-6">
          <PUI.Dropdown.menu_button id="dropdown-actions" content_class="w-56">
            <.icon name="hero-ellipsis-vertical" class="size-4" /> Actions
            <:items>
              <PUI.Dropdown.menu_item navigate="/select">
                <.icon name="hero-cog" class="size-4" /> Settings (navigate)
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_item variant="destructive">
                <.icon name="hero-trash" class="size-4" /> Delete User Profile
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_item variant="destructive">
                <.icon name="hero-trash" class="size-4" /> Delete User Data
              </PUI.Dropdown.menu_item>
              <PUI.Dropdown.menu_separator />
              <PUI.Dropdown.menu_item variant="default" phx-click="undo">
                <.icon name="hero-arrow-uturn-left" class="size-4" /> Undo
              </PUI.Dropdown.menu_item>
            </:items>
          </PUI.Dropdown.menu_button>
        </div>
        <AppWeb.DocComponents.code_block
          code={~s|<.menu_button content_class="w-56">
    Actions
    <:items>
    <.menu_item navigate="/settings">
      Settings
    </.menu_item>
    <.menu_item variant="destructive">
      Delete Profile
    </.menu_item>
    <.menu_separator />
    <.menu_item phx-click="undo">
      Undo
    </.menu_item>
    </:items>
    </.menu_button>|}
          language="heex"
        />
      </AppWeb.DocComponents.example_card>
      
    <!-- Component API Section -->
      <AppWeb.DocComponents.component_api_section
        module="PUI.Dropdown"
        function="menu_button/1"
        import_statement="use PUI"
        props={[
          %{
            name: "variant",
            type: "string",
            default: "\"secondary\"",
            description:
              "Button variant style (default, secondary, destructive, outline, ghost, link)"
          },
          %{
            name: "class",
            type: "string",
            default: "\"\"",
            description: "Additional CSS classes for the button"
          },
          %{
            name: "content_class",
            type: "string",
            default: "\"\"",
            description: "CSS classes for the dropdown content container"
          }
        ]}
      >
        <:description>
          A dropdown menu component that displays actions and options when triggered.
          Supports keyboard shortcuts, separators, destructive actions, and custom content.
          Built on top of Floating UI for precise positioning and smooth animations.
        </:description>
        <:example title="With Navigation">
          <PUI.Dropdown.menu_button content_class="w-48">
            Navigate
            <:item navigate="/profile">View Profile</:item>
            <:item patch="/settings">Edit Settings</:item>
            <:item href="/logout">Sign Out</:item>
          </PUI.Dropdown.menu_button>
        </:example>
      </AppWeb.DocComponents.component_api_section>
      
    <!-- Usage Guidelines -->
      <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 bg-zinc-50 dark:bg-zinc-800/50">
        <h3 class="text-lg font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Usage Guidelines</h3>
        <div class="space-y-4 text-sm text-zinc-600 dark:text-zinc-400">
          <div>
            <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">
              Simple Items vs Custom Items
            </h4>
            <p>
              Use the
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">&lt;:item&gt;</code>
              slot for quick
              menu items with automatic rendering. Use
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">&lt;:items&gt;</code>
              when you need separators or more complex layouts with <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">&lt;.menu_item&gt;</code>.
            </p>
          </div>
          <div>
            <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">Navigation Options</h4>
            <p>
              Menu items support
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">navigate</code>
              (LiveView navigation),
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">patch</code>
              (LiveView patch), and
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">href</code>
              (standard links).
            </p>
          </div>
          <div>
            <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">Destructive Actions</h4>
            <p>
              Always use
              <code class="px-1 py-0.5 bg-zinc-200 dark:bg-zinc-700 rounded">
                variant="destructive"
              </code>
              for actions
              that delete, remove, or have significant consequences. This provides visual warning cues to users.
            </p>
          </div>
          <div>
            <h4 class="font-medium text-zinc-900 dark:text-zinc-100 mb-1">Accessibility</h4>
            <p>
              Dropdowns include proper ARIA attributes (role="menuitem", aria-haspopup, aria-expanded) and support
              keyboard navigation for accessible interaction.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp demo_toast(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <h2 class="text-lg font-semibold mb-4">Toast Notifications</h2>
        <p class="text-muted-foreground mb-4">
          Toast notifications appear temporarily to provide feedback to users.
        </p>
      </div>

      <div>
        <h3 class="text-md font-medium mb-3">Placement</h3>
      </div>
      <div class="w-1/2 grid grid-cols-3 gap-2">
        <.button phx-click="set_flash_placement" phx-value-placement="top-left" variant="secondary">
          <.icon name="hero-arrow-up-left" class="size-4" /> Top Left
        </.button>
        <.button phx-click="set_flash_placement" phx-value-placement="top-center" variant="secondary">
          <.icon name="hero-arrow-up" class="size-4" /> Top Center
        </.button>
        <.button phx-click="set_flash_placement" phx-value-placement="top-right" variant="secondary">
          <.icon name="hero-arrow-up-right" class="size-4" /> Top Right
        </.button>
      </div>
      <div class="w-1/2 grid grid-cols-3 gap-2">
        <.button phx-click="set_flash_placement" phx-value-placement="bottom-left" variant="secondary">
          <.icon name="hero-arrow-down-left" class="size-4" /> Bottom Left
        </.button>
        <.button
          phx-click="set_flash_placement"
          phx-value-placement="bottom-center"
          variant="secondary"
        >
          <.icon name="hero-arrow-down" class="size-4" /> Bottom Center
        </.button>
        <.button
          phx-click="set_flash_placement"
          phx-value-placement="bottom-right"
          variant="secondary"
        >
          <.icon name="hero-arrow-down-right" class="size-4" /> Bottom Right
        </.button>
      </div>

      <div>
        <h3 class="text-md font-medium mb-3">Preview</h3>
      </div>

      <.button phx-click="put_flash" variant="secondary">
        <.icon name="hero-bell" class="size-4" /> Test Flash Message
      </.button>

      <.button phx-click="put_basic_flash" variant="secondary">
        <.icon name="hero-bell" class="size-4" /> Test Basic Message
      </.button>
      <.button phx-click="put_redirect_flash" variant="destructive">
        <.icon name="hero-bell" class="size-4" /> To non liveview page
      </.button>

      <.button phx-click="send_flash" variant="default">
        <.icon name="hero-bell" class="size-4" /> Use send_flash
      </.button>

      <.button phx-click="update_flash" variant="default">
        <.icon name="hero-bell" class="size-4" /> Update Flash
      </.button>

      <.button phx-click="custom_flash" variant="outline">
        <.icon name="hero-bell" class="size-4" /> Customize Flash
      </.button>

      <div class="p-6 bg-accent/30 rounded-lg border border-border">
        <h3 class="text-sm font-semibold mb-2">Features</h3>
        <ul class="text-sm text-muted-foreground space-y-1 list-disc list-inside">
          <li>Stacked animations with peek effect</li>
          <li>Swipe to dismiss</li>
          <li>Auto-dismiss with configurable duration</li>
          <li>Accessible with ARIA attributes</li>
        </ul>
      </div>
    </div>
    """
  end
end
