defmodule AppWeb.Live.ComponentHarness do
  use AppWeb, :live_view
  use PUI

  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    form = build_harness_form(%{"name" => "John Doe", "choice" => "beta", "notes" => "hello"})
    seo = harness_seo(socket.assigns.live_action)

    {:ok,
     socket
     |> assign(:click_count, 0)
     |> assign(:dropdown_action, "none")
     |> assign(:dialog_open?, false)
     |> assign(:selected_choice, "beta")
     |> assign(:active_tab, "overview")
     |> assign(:form, form)
     |> assign(:popover_count, 0)
     |> assign(:flash_position, "top-center")
     |> assign(:page_title, seo.title)
     |> assign(:seo, seo)}
  end

  def handle_event("button_click", _params, socket) do
    {:noreply, update(socket, :click_count, &(&1 + 1))}
  end

  def handle_event("validate_inputs", params, socket) do
    {:noreply, assign(socket, :form, build_harness_form(params["demo"] || %{}, validate?: true))}
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

  def handle_event("select_changed", %{"demo" => params}, socket) do
    choice = Map.get(params, "choice", socket.assigns.selected_choice)

    form =
      params
      |> Map.put("name", Map.get(params, "name", socket.assigns.form[:name].value))
      |> Map.put("notes", Map.get(params, "notes", socket.assigns.form[:notes].value))
      |> build_harness_form(validate?: true)

    {:noreply, socket |> assign(:selected_choice, choice) |> assign(:form, form)}
  end

  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
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

  defp render_component(assigns) when assigns.live_action == :tabs do
    ~H"""
    <div class="space-y-6">
      <.tabs id="client-tabs" default_value="overview">
        <:trigger value="overview">Overview</:trigger>
        <:trigger value="analytics">Analytics</:trigger>
        <:trigger value="reports" disabled>Reports</:trigger>
        <:content value="overview">
          <div id="client-tab-panel-overview">Overview panel</div>
        </:content>
        <:content value="analytics">
          <div id="client-tab-panel-analytics">Analytics panel</div>
        </:content>
        <:content value="reports">
          <div id="client-tab-panel-reports">Reports panel</div>
        </:content>
      </.tabs>

      <.tabs
        id="server-tabs"
        value={@active_tab}
        client_controlled={false}
        variant="line"
      >
        <:trigger value="overview" phx-click="select_tab" phx-value-tab="overview">
          Overview
        </:trigger>
        <:trigger value="settings" phx-click="select_tab" phx-value-tab="settings">
          Settings
        </:trigger>
        <:content value="overview">
          <div id="server-tab-panel-overview">Server overview</div>
        </:content>
        <:content value="settings">
          <div id="server-tab-panel-settings">Server settings</div>
        </:content>
      </.tabs>

      <p id="server-tab-value">Server active: {@active_tab}</p>
    </div>
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
        title="Harness dialog"
      >
        <div id="server-dialog-body" class="space-y-4">
          <p>Dialog content</p>
          <.form for={@form} id="dialog-form" phx-change="validate_inputs" class="space-y-4">
            <.input field={@form[:name]} label="Full Name" />
            <.select
              id="dialog-select"
              field={@form[:choice]}
              label="Category"
              options={[{"alpha", "Alpha"}, {"beta", "Beta"}, {"gamma", "Gamma"}]}
            />
          </.form>
        </div>
        <:footer>
          <div class="flex justify-end">
            <.button id="server-dialog-close" variant="secondary" phx-click="close_dialog">
              Close Dialog
            </.button>
          </div>
        </:footer>
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
      :tabs -> "Tabs Harness"
    end
  end

  defp harness_seo(action) do
    AppWeb.Seo.build_meta(%{
      title: page_title(action),
      description: "Internal component harness used to validate demo behavior.",
      path: harness_path(action),
      robots: "noindex,nofollow"
    })
  end

  defp harness_path(action), do: "/__test__/components/#{action}"

  defp build_harness_form(params, opts \\ []) do
    errors =
      []
      |> maybe_error(:name, blank?(params["name"]), "Please enter your full name.")
      |> maybe_error(:notes, blank?(params["notes"]), "Please add a few notes.")
      |> maybe_error(:choice, blank?(params["choice"]), "Please select an option.")

    form_opts =
      [as: :demo]
      |> maybe_put_option(:errors, errors, errors != [])
      |> maybe_put_option(:action, :validate, Keyword.get(opts, :validate?, false))

    to_form(params, form_opts)
  end

  defp maybe_error(errors, field, true, message), do: [{field, {message, []}} | errors]
  defp maybe_error(errors, _field, false, _message), do: errors

  defp maybe_put_option(opts, key, value, true), do: Keyword.put(opts, key, value)
  defp maybe_put_option(opts, _key, _value, false), do: opts

  defp blank?(value), do: value in [nil, ""]
end
