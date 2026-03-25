defmodule AppWeb.Live.ComponentHarness do
  use AppWeb, :live_view
  use PUI

  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    form = to_form(%{"name" => "John Doe", "choice" => "beta", "notes" => "hello"})

    {:ok,
     socket
     |> assign(:click_count, 0)
     |> assign(:dropdown_action, "none")
     |> assign(:dialog_open?, false)
     |> assign(:selected_choice, "beta")
     |> assign(:form, form)
     |> assign(:popover_count, 0)
     |> assign(:flash_position, "top-center")}
  end

  def handle_event("button_click", _params, socket) do
    {:noreply, update(socket, :click_count, &(&1 + 1))}
  end

  def handle_event("validate_inputs", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end

  def handle_event("dropdown_action", %{"action" => action}, socket) do
    {:noreply, assign(socket, :dropdown_action, action)}
  end

  def handle_event("open_dialog", _params, socket) do
    {:noreply, assign(socket, :dialog_open?, true)}
  end

  def handle_event("close_dialog", _params, socket) do
    {:noreply, assign(socket, :dialog_open?, false)}
  end

  def handle_event("select_changed", %{"choice" => choice} = params, socket) do
    form =
      params
      |> Map.put("name", Map.get(params, "name", socket.assigns.form[:name].value))
      |> Map.put("notes", Map.get(params, "notes", socket.assigns.form[:notes].value))
      |> to_form()

    {:noreply, socket |> assign(:selected_choice, choice) |> assign(:form, form)}
  end

  def handle_event("popover_increment", _params, socket) do
    {:noreply, update(socket, :popover_count, &(&1 + 1))}
  end

  def handle_event("send_flash", _params, socket) do
    {:noreply, put_flash(socket, :info, "Harness flash message")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section id="component-harness" class="space-y-6">
        <h1 id="harness-title" class="text-2xl font-semibold">{page_title(@live_action)}</h1>
        <PUI.Flash.flash_group
          :if={@live_action == :flash}
          flash={@flash}
          position={@flash_position}
          live={true}
        />
        {render_component(assigns)}
      </section>
    </Layouts.app>
    """
  end

  defp render_component(%{live_action: :button} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.button id="button-action" phx-click="button_click">Primary Action</.button>
      <.button id="button-link" patch={~p"/__test__/components/button"} variant="link">
        Stay On Page
      </.button>
      <.button id="button-icon" size="icon" aria-label="Favorite item">
        <.icon name="hero-heart" class="size-4" />
      </.button>
      <p id="button-count">Clicked: {@click_count}</p>
    </div>
    """
  end

  defp render_component(%{live_action: :input} = assigns) do
    ~H"""
    <.form for={@form} id="inputs-form" phx-change="validate_inputs" class="space-y-4">
      <.input field={@form[:name]} label="Full Name" />
      <.textarea field={@form[:notes]} label="Notes" />
      <.checkbox id="terms-checkbox" label="Accept terms" />
      <.switch id="email-switch" label="Email notifications" />
      <p id="input-value">{@form[:name].value}</p>
    </.form>
    """
  end

  defp render_component(assigns = %{live_action: :select}) do
    ~H"""
    <.form for={@form} id="select-form" phx-change="select_changed" class="space-y-4">
      <.select
        id="harness-select"
        field={@form[:choice]}
        label="Harness Select"
        searchable={true}
        options={[{"alpha", "Alpha"}, {"beta", "Beta"}, {"gamma", "Gamma"}]}
      />
      <p id="select-value">Selected: {@selected_choice}</p>
    </.form>
    """
  end

  defp render_component(assigns) when assigns.live_action == :dropdown do
    ~H"""
    <div class="space-y-4">
      <PUI.Dropdown.menu_button id="harness-dropdown" content_class="w-48">
        Actions
        <:item phx-click="dropdown_action" phx-value-action="edit">Edit</:item>
        <:item phx-click="dropdown_action" phx-value-action="archive">Archive</:item>
        <:item phx-click="dropdown_action" phx-value-action="delete" variant="destructive">
          Delete
        </:item>
      </PUI.Dropdown.menu_button>
      <p id="dropdown-result">{@dropdown_action}</p>
    </div>
    """
  end

  defp render_component(assigns) when assigns.live_action == :dialog do
    ~H"""
    <div class="space-y-4">
      <.button id="server-dialog-open" phx-click="open_dialog">Open Dialog</.button>
      <.dialog
        id="server-dialog"
        aria-label="Harness dialog"
        show={@dialog_open?}
        on_cancel={JS.push("close_dialog")}
      >
        <div id="server-dialog-body" class="space-y-4">
          <p>Dialog content</p>
          <.button id="server-dialog-close" variant="secondary" phx-click="close_dialog">
            Close Dialog
          </.button>
        </div>
      </.dialog>
    </div>
    """
  end

  defp render_component(assigns) when assigns.live_action == :popover do
    ~H"""
    <div class="space-y-4">
      <.popover_base
        id="harness-popover"
        phx-hook="PUI.Popover"
        data-placement="bottom"
        class="w-fit"
      >
        <.button id="popover-trigger" aria-haspopup="menu">Open Popover</.button>
        <:popup class="aria-hidden:hidden block rounded-md border bg-popover p-4 shadow-md">
          <div class="space-y-3">
            <p id="popover-count">Count: {@popover_count}</p>
            <.button id="popover-increment" phx-click="popover_increment" size="sm">
              Increment
            </.button>
          </div>
        </:popup>
      </.popover_base>

      <.tooltip id="harness-tooltip" placement="top">
        <button id="tooltip-trigger" type="button" class="rounded border px-3 py-2">
          Tooltip Trigger
        </button>
        <:tooltip>Tooltip content</:tooltip>
      </.tooltip>
    </div>
    """
  end

  defp render_component(assigns) when assigns.live_action == :alert do
    ~H"""
    <div class="space-y-4">
      <.alert id="status-alert">
        <:title>Saved</:title>
        <:description>Changes persisted successfully.</:description>
      </.alert>
      <.alert id="destructive-alert" variant="destructive">
        <:title>Error</:title>
        <:description>Unable to save changes.</:description>
      </.alert>
    </div>
    """
  end

  defp render_component(assigns) when assigns.live_action == :flash do
    ~H"""
    <div class="space-y-4">
      <.button id="send-flash" phx-click="send_flash">Send Flash</.button>
    </div>
    """
  end

  defp render_component(assigns) when assigns.live_action == :container do
    ~H"""
    <PUI.Container.card id="profile-card">
      <PUI.Container.card_header>
        <PUI.Container.card_title>Profile</PUI.Container.card_title>
        <PUI.Container.card_description>Manage account details.</PUI.Container.card_description>
      </PUI.Container.card_header>
      <PUI.Container.card_content>
        <p id="profile-email">john@example.com</p>
      </PUI.Container.card_content>
      <PUI.Container.card_footer class="gap-2">
        <.button id="save-profile">Save Changes</.button>
      </PUI.Container.card_footer>
    </PUI.Container.card>
    """
  end

  defp render_component(assigns) when assigns.live_action == :loading do
    ~H"""
    <div class="space-y-4">
      <p id="loading-description">Loading bar is mounted from the root layout.</p>
    </div>
    """
  end

  defp page_title(action) do
    case action do
      :button -> "Button Harness"
      :input -> "Input Harness"
      :select -> "Select Harness"
      :dropdown -> "Dropdown Harness"
      :dialog -> "Dialog Harness"
      :popover -> "Popover Harness"
      :alert -> "Alert Harness"
      :flash -> "Flash Harness"
      :container -> "Container Harness"
      :loading -> "Loading Harness"
    end
  end
end
