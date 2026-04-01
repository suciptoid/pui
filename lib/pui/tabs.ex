defmodule PUI.Tabs do
  @moduledoc """
  Accessible tabs for switching between related panels of content.

  PUI tabs follow the shadcn/ui visual language while keeping a Phoenix-friendly,
  server-renderable API. The component renders correct WAI-ARIA roles and states
  on the server, then enhances the experience with the `PUI.Tabs` hook for arrow
  key navigation, roving focus, and optional client-side activation.

  Use `tabs/1` with `:trigger` and `:content` slots. Triggers and panels are
  matched by their shared `value`.

  ## Basic Usage

      <.tabs id="account-tabs" default_value="account">
        <:trigger value="account">Account</:trigger>
        <:trigger value="password">Password</:trigger>
        <:content value="account">
          Make changes to your account here.
        </:content>
        <:content value="password">
          Change your password here.
        </:content>
      </.tabs>

  ## Server-Controlled Tabs

  Set `value` from your assigns and push a LiveView event from each trigger when
  you want the server to be the source of truth:

      <.tabs id="settings-tabs" value={@active_tab} client_controlled={false}>
        <:trigger value="profile" phx-click="select_tab" phx-value-tab="profile">
          Profile
        </:trigger>
        <:trigger value="billing" phx-click="select_tab" phx-value-tab="billing">
          Billing
        </:trigger>
        <:content value="profile">Profile settings...</:content>
        <:content value="billing">Billing settings...</:content>
      </.tabs>

  ## Vertical Tabs

      <.tabs id="preferences-tabs" default_value="notifications" orientation="vertical">
        <:trigger value="notifications">Notifications</:trigger>
        <:trigger value="security">Security</:trigger>
        <:content value="notifications">Notification preferences...</:content>
        <:content value="security">Security preferences...</:content>
      </.tabs>

  ## Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `id` | `string` | auto-generated | Unique id used to link tabs and panels |
  | `value` | `string` | `nil` | Active value when the server controls selection |
  | `default_value` | `string` | first enabled trigger | Initial active value for client-controlled tabs |
  | `orientation` | `string` | `"horizontal"` | `"horizontal"` or `"vertical"` |
  | `activation_mode` | `string` | `"manual"` | `"automatic"` or `"manual"` keyboard activation |
  | `client_controlled` | `boolean` | `true` | Whether the hook updates active state in the browser |
  | `variant` | `string` | `"default"` | `"default"`, `"line"`, or `"unstyled"` |
  | `class` | `string` | `""` | Additional root classes |
  | `list_class` | `string` | `""` | Additional classes for the tab list |
  | `panels_class` | `string` | `""` | Additional classes for the panels wrapper |

  ## Trigger Slot Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `value` | `string` | **required** | Tab value used to match a panel |
  | `id` | `string` | generated | Custom trigger id |
  | `class` | `string` | `""` | Additional trigger classes |
  | `disabled` | `boolean` | `false` | Disables pointer and keyboard activation |
  | `phx-click` | `any` | `nil` | LiveView event or JS command for server-controlled tabs |
  | `phx-target` | `any` | `nil` | Optional event target |
  | `phx-value-tab` | `string` | `nil` | Tab value sent with `phx-click` |

  ## Content Slot Attributes

  | Attribute | Type | Default | Description |
  |-----------|------|---------|-------------|
  | `value` | `string` | **required** | Panel value matched with a trigger |
  | `id` | `string` | generated | Custom panel id |
  | `class` | `string` | `""` | Additional panel classes |

  ## Accessibility

  - Uses `role="tablist"`, `role="tab"`, and `role="tabpanel"`
  - Supports roving focus with arrow keys, `Home`, and `End`
  - Defaults to manual activation so arrow keys move focus and `Space`/`Enter` activate
  - Supports automatic and manual activation modes
  - Keeps inactive panels hidden from assistive technology and visual layout
  """

  use Phoenix.Component

  attr :id, :string, default: nil
  attr :value, :string, default: nil
  attr :default_value, :string, default: nil
  attr :orientation, :string, default: "horizontal", values: ["horizontal", "vertical"]
  attr :activation_mode, :string, default: "manual", values: ["automatic", "manual"]
  attr :client_controlled, :boolean, default: true
  attr :variant, :string, default: "default", values: ["default", "line", "unstyled"]
  attr :class, :string, default: ""
  attr :list_class, :string, default: ""
  attr :panels_class, :string, default: ""
  attr :rest, :global

  slot :trigger, required: true do
    attr :value, :string, required: true
    attr :id, :string
    attr :class, :string
    attr :disabled, :boolean
    attr :"phx-click", :any
    attr :"phx-target", :any
    attr :"phx-value-tab", :string
  end

  slot :content, required: true do
    attr :value, :string, required: true
    attr :id, :string
    attr :class, :string
  end

  @doc """
  Renders an accessible tabs interface with server and client control modes.

  The server renders the active tab state for the initial response, while the
  `PUI.Tabs` hook adds keyboard support and optional browser-managed activation.

  ## Examples

      <.tabs id="team-tabs" default_value="members">
        <:trigger value="members">Members</:trigger>
        <:trigger value="billing">Billing</:trigger>
        <:content value="members">Manage team members.</:content>
        <:content value="billing">Manage billing details.</:content>
      </.tabs>

      <.tabs id="live-tabs" value={@active_tab} client_controlled={false}>
        <:trigger value="overview" phx-click="select_tab" phx-value-tab="overview">
          Overview
        </:trigger>
        <:trigger value="activity" phx-click="select_tab" phx-value-tab="activity">
          Activity
        </:trigger>
        <:content value="overview">Overview panel.</:content>
        <:content value="activity">Activity panel.</:content>
      </.tabs>
  """
  def tabs(assigns) do
    assigns = assign_new(assigns, :id, fn -> "tabs-#{System.unique_integer([:positive])}" end)
    active_value = resolve_active_value(assigns.value, assigns.default_value, assigns.trigger)
    is_unstyled = assigns.variant == "unstyled"

    assigns =
      assigns
      |> assign(:active_value, active_value)
      |> assign(:is_unstyled, is_unstyled)
      |> assign(:root_classes, root_classes(assigns.orientation, is_unstyled, assigns.class))
      |> assign(
        :list_classes,
        list_classes(assigns.variant, assigns.orientation, is_unstyled, assigns.list_class)
      )
      |> assign(
        :panels_classes,
        panels_classes(assigns.orientation, is_unstyled, assigns.panels_class)
      )

    ~H"""
    <div
      id={@id}
      phx-hook="PUI.Tabs"
      data-value={@value || @active_value}
      data-default-value={@default_value || @active_value}
      data-orientation={@orientation}
      data-activation-mode={@activation_mode}
      data-client-controlled={to_string(@client_controlled)}
      class={@root_classes}
      {@rest}
    >
      <div role="tablist" aria-orientation={@orientation} class={@list_classes}>
        <button
          :for={tab <- @trigger}
          id={trigger_id(@id, tab, @trigger)}
          type="button"
          role="tab"
          data-value={tab[:value]}
          data-state={tab_state(tab[:value], @active_value)}
          aria-selected={to_string(active?(tab[:value], @active_value))}
          aria-controls={content_id(@id, tab[:value], @content)}
          tabindex={tabindex(tab[:value], @active_value, tab[:disabled])}
          disabled={tab[:disabled]}
          data-disabled={if tab[:disabled], do: "true"}
          phx-click={tab[:"phx-click"]}
          phx-target={tab[:"phx-target"]}
          phx-value-tab={tab[:"phx-value-tab"] || tab[:value]}
          class={
            trigger_classes(
              @variant,
              @orientation,
              @is_unstyled,
              tab[:class]
            )
          }
        >
          {render_slot(tab)}
        </button>
      </div>

      <div class={@panels_classes}>
        <div
          :for={panel <- @content}
          id={content_id(@id, panel[:value], @content)}
          role="tabpanel"
          data-value={panel[:value]}
          data-state={tab_state(panel[:value], @active_value)}
          aria-labelledby={trigger_id(@id, panel[:value], @trigger)}
          tabindex="0"
          hidden={not active?(panel[:value], @active_value)}
          class={panel_classes(@is_unstyled, panel[:class])}
        >
          {render_slot(panel)}
        </div>
      </div>
    </div>
    """
  end

  defp resolve_active_value(value, default_value, triggers) do
    cond do
      present?(value) ->
        value

      present?(default_value) ->
        default_value

      true ->
        triggers
        |> Enum.find(&(not Map.get(&1, :disabled, false)))
        |> case do
          nil -> nil
          trigger -> trigger[:value]
        end
    end
  end

  defp root_classes("vertical", true, class), do: [class]
  defp root_classes(_orientation, true, class), do: [class]
  defp root_classes("vertical", false, class), do: ["flex items-start gap-6", class]
  defp root_classes(_orientation, false, class), do: ["w-full space-y-4", class]

  defp list_classes(_variant, _orientation, true, class), do: [class]

  defp list_classes("default", "vertical", false, class) do
    [
      "bg-muted text-muted-foreground inline-flex h-auto min-w-44 flex-col items-stretch justify-start rounded-lg p-1",
      class
    ]
  end

  defp list_classes("default", _orientation, false, class) do
    [
      "bg-muted text-muted-foreground inline-flex h-10 w-fit items-center justify-center rounded-lg p-1",
      class
    ]
  end

  defp list_classes("line", "vertical", false, class) do
    [
      "inline-flex h-auto min-w-44 flex-col items-stretch justify-start border-l border-border",
      class
    ]
  end

  defp list_classes("line", _orientation, false, class) do
    [
      "inline-flex h-auto w-fit items-center justify-start border-b border-border",
      class
    ]
  end

  defp panels_classes("vertical", true, class), do: ["min-w-0 flex-1", class]
  defp panels_classes(_orientation, true, class), do: [class]
  defp panels_classes("vertical", false, class), do: ["min-w-0 flex-1", class]
  defp panels_classes(_orientation, false, class), do: ["space-y-4", class]

  defp trigger_classes(_variant, _orientation, true, class), do: [class]

  defp trigger_classes("default", "vertical", false, class) do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 inline-flex min-w-0 items-center justify-start gap-2 whitespace-nowrap rounded-md px-3 py-2 text-sm font-medium transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50",
      "data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-xs",
      "data-[state=inactive]:text-muted-foreground data-[state=inactive]:hover:bg-background/60 data-[state=inactive]:hover:text-foreground",
      class
    ]
  end

  defp trigger_classes("default", _orientation, false, class) do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 inline-flex min-w-0 items-center justify-center gap-2 whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50",
      "data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-xs",
      "data-[state=inactive]:text-muted-foreground data-[state=inactive]:hover:text-foreground",
      class
    ]
  end

  defp trigger_classes("line", "vertical", false, class) do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 -ml-px inline-flex min-w-0 items-center justify-start gap-2 whitespace-nowrap border-l-2 px-4 py-2 text-sm font-medium transition-[color,border-color,box-shadow] outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50",
      "data-[state=active]:border-primary data-[state=active]:text-foreground",
      "data-[state=inactive]:border-transparent data-[state=inactive]:text-muted-foreground data-[state=inactive]:hover:text-foreground",
      class
    ]
  end

  defp trigger_classes("line", _orientation, false, class) do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 -mb-px inline-flex min-w-0 items-center justify-center gap-2 whitespace-nowrap border-b-2 px-4 py-2 text-sm font-medium transition-[color,border-color,box-shadow] outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50",
      "data-[state=active]:border-primary data-[state=active]:text-foreground",
      "data-[state=inactive]:border-transparent data-[state=inactive]:text-muted-foreground data-[state=inactive]:hover:text-foreground",
      class
    ]
  end

  defp panel_classes(true, class), do: [class]

  defp panel_classes(false, class) do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 outline-none focus-visible:ring-[3px]",
      class
    ]
  end

  defp active?(value, active_value), do: to_string(value || "") == to_string(active_value || "")

  defp tab_state(value, active_value),
    do: if(active?(value, active_value), do: "active", else: "inactive")

  defp tabindex(_value, _active_value, disabled) when disabled in [true, "true"], do: "-1"

  defp tabindex(value, active_value, _disabled),
    do: if(active?(value, active_value), do: "0", else: "-1")

  defp trigger_id(_root_id, %{id: id}, _triggers) when id not in [nil, ""], do: id

  defp trigger_id(root_id, value, _triggers) when is_binary(value),
    do: "#{root_id}-trigger-#{normalize_dom_token(value)}"

  defp trigger_id(root_id, %{value: value}, triggers), do: trigger_id(root_id, value, triggers)

  defp content_id(root_id, value, contents) when is_binary(value) do
    case Enum.find(contents, &(Map.get(&1, :value) == value and present?(Map.get(&1, :id)))) do
      nil -> "#{root_id}-panel-#{normalize_dom_token(value)}"
      panel -> panel[:id]
    end
  end

  defp normalize_dom_token(value) do
    value
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9_-]+/u, "-")
  end

  defp present?(value), do: value not in [nil, ""]
end
