defmodule PUI.DatePickerComponent do
  use Phoenix.LiveComponent

  import PUI.Container, only: [icon: 1]

  alias PUI.DatePicker
  alias Phoenix.LiveView.JS

  def update(assigns, socket) do
    mode = Map.fetch!(assigns, :mode)
    number_of_months = max(Map.get(assigns, :number_of_months, 1), 1)
    value = if mode == "single", do: DatePicker.normalize_date_value(assigns.value), else: nil

    from_value =
      if mode == "range", do: DatePicker.normalize_date_value(assigns.from_value), else: nil

    to_value =
      if mode == "range", do: DatePicker.normalize_date_value(assigns.to_value), else: nil

    default_month = DatePicker.normalize_date_value(assigns.default_month)
    min = DatePicker.normalize_date_value(Map.get(assigns, :min))
    max = DatePicker.normalize_date_value(Map.get(assigns, :max))

    visible_month =
      cond do
        socket.assigns[:visible_month] == nil ->
          resolve_visible_month(mode, default_month, value, from_value, to_value)

        mode == "single" and socket.assigns[:value] != value ->
          maybe_preserve_visible_month(
            mode,
            socket.assigns.visible_month,
            default_month,
            value,
            from_value,
            to_value,
            number_of_months
          )

        mode == "range" and
            (socket.assigns[:from_value] != from_value or socket.assigns[:to_value] != to_value) ->
          maybe_preserve_visible_month(
            mode,
            socket.assigns.visible_month,
            default_month,
            value,
            from_value,
            to_value,
            number_of_months
          )

        true ->
          socket.assigns.visible_month
      end
      |> DatePicker.clamp_visible_month(min, max, number_of_months)

    socket =
      socket
      |> assign(assigns)
      |> assign(
        mode: mode,
        value: value,
        from_value: from_value,
        to_value: to_value,
        picker_id: assigns.id,
        default_month: default_month,
        min: min,
        max: max,
        visible_month: visible_month,
        number_of_months: number_of_months,
        selectable_month: Map.get(assigns, :selectable_month, true),
        footer: Map.get(assigns, :footer, []),
        months:
          build_months(
            assigns.id,
            mode,
            visible_month,
            number_of_months,
            value,
            from_value,
            to_value,
            min,
            max
          )
      )

    {:ok, socket}
  end

  def handle_event("navigate", %{"direction" => direction}, socket) do
    offset = if direction == "prev", do: -1, else: 1

    visible_month =
      socket.assigns.visible_month
      |> DatePicker.shift_month(offset)
      |> DatePicker.clamp_visible_month(
        socket.assigns.min,
        socket.assigns.max,
        socket.assigns.number_of_months
      )

    {:noreply, assign_calendar(socket, visible_month: visible_month)}
  end

  def handle_event("select", %{"date" => date}, %{assigns: %{mode: "single"}} = socket) do
    value = DatePicker.normalize_date_value(date)

    if DatePicker.within_bounds?(value, socket.assigns.min, socket.assigns.max) do
      visible_month =
        maybe_preserve_visible_month(
          "single",
          socket.assigns.visible_month,
          socket.assigns.default_month,
          value,
          nil,
          nil,
          socket.assigns.number_of_months
        )
        |> DatePicker.clamp_visible_month(
          socket.assigns.min,
          socket.assigns.max,
          socket.assigns.number_of_months
        )

      {:noreply, assign_calendar(socket, value: value, visible_month: visible_month)}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "select",
        %{"from" => from_value, "to" => to_value},
        %{assigns: %{mode: "range"}} = socket
      ) do
    from_value = DatePicker.normalize_date_value(from_value)
    to_value = DatePicker.normalize_date_value(to_value)

    if range_values_within_bounds?([from_value, to_value], socket.assigns.min, socket.assigns.max) do
      visible_month =
        maybe_preserve_visible_month(
          "range",
          socket.assigns.visible_month,
          socket.assigns.default_month,
          nil,
          from_value,
          to_value,
          socket.assigns.number_of_months
        )
        |> DatePicker.clamp_visible_month(
          socket.assigns.min,
          socket.assigns.max,
          socket.assigns.number_of_months
        )

      {:noreply,
       assign_calendar(socket,
         from_value: from_value,
         to_value: to_value,
         visible_month: visible_month
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select_month", %{"month" => month, "offset" => offset}, socket) do
    offset = String.to_integer(offset)
    month = String.to_integer(month)

    current_month =
      socket.assigns.visible_month
      |> DatePicker.visible_month_for_offset(offset)
      |> DatePicker.normalize_date!()

    visible_month =
      DatePicker.set_visible_month(
        current_month.year,
        month,
        offset,
        socket.assigns.min,
        socket.assigns.max,
        socket.assigns.number_of_months
      )

    {:noreply, assign_calendar(socket, visible_month: visible_month)}
  end

  def handle_event("select_year", %{"year" => year, "offset" => offset}, socket) do
    offset = String.to_integer(offset)
    year = String.to_integer(year)

    current_month =
      socket.assigns.visible_month
      |> DatePicker.visible_month_for_offset(offset)
      |> DatePicker.normalize_date!()

    visible_month =
      DatePicker.set_visible_month(
        year,
        current_month.month,
        offset,
        socket.assigns.min,
        socket.assigns.max,
        socket.assigns.number_of_months
      )

    {:noreply, assign_calendar(socket, visible_month: visible_month)}
  end

  def render(%{mode: "single"} = assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PUI.DatePicker"
      data-placement="bottom-start"
      class="relative"
    >
      <input
        id={@input_id}
        data-pui="date-picker-value"
        type="hidden"
        name={@name}
        value={@value || ""}
        aria-hidden="true"
        style={DatePicker.hidden_input_style()}
      />

      <button
        id={@trigger_id}
        data-pui="date-picker-trigger"
        type="button"
        aria-haspopup="dialog"
        aria-expanded="false"
        aria-controls={@popup_id}
        aria-invalid={if @errors != [], do: "true"}
        data-empty={is_nil(DatePicker.format_date_label(@value))}
        class={DatePicker.trigger_classes(@class)}
      >
        <span class="flex min-w-0 flex-1 items-center gap-2 overflow-hidden">
          <.icon name="hero-calendar" class="size-4 shrink-0 opacity-70" />
          <span
            data-pui="date-picker-label"
            data-placeholder={@placeholder}
            class="block min-w-0 flex-1 truncate text-left"
          >
            {DatePicker.format_date_label(@value) || @placeholder}
          </span>
        </span>
        <.icon name="hero-chevron-down" class="size-4 shrink-0 opacity-50" />
      </button>

      <div
        id={@popup_id}
        data-pui="date-picker-popup"
        data-grid-cols="7"
        data-grid-navigation="calendar"
        data-focus-date={focus_date("single", @value, nil, nil)}
        role="listbox"
        tabindex="-1"
        aria-label="Calendar"
        aria-hidden="true"
        data-side="bottom"
        data-floating-strategy="absolute"
        data-reference-hidden="false"
        class={DatePicker.content_classes(@content_class)}
      >
        <div class="p-1.5">
          <.month_grid
            month={hd(@months)}
            mode="single"
            input_id={@input_id}
            picker_id={@id}
            trigger_id={@trigger_id}
            selectable_month={@selectable_month}
            min={@min}
            max={@max}
            number_of_months={@number_of_months}
            show_prev?={true}
            show_next?={true}
            can_navigate_prev?={can_navigate?(@visible_month, -1, @min, @max, @number_of_months)}
            can_navigate_next?={can_navigate?(@visible_month, 1, @min, @max, @number_of_months)}
            myself={@myself}
          />
        </div>
        <div :if={@footer != []} class="border-t border-border p-2">
          {render_slot(@footer)}
        </div>
      </div>
    </div>
    """
  end

  def render(%{mode: "range"} = assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PUI.DatePicker"
      data-placement="bottom-start"
      class="relative"
    >
      <input
        id={@from_input_id}
        data-pui="range-start-value"
        type="hidden"
        name={@from_name}
        value={@from_value || ""}
        aria-hidden="true"
        style={DatePicker.hidden_input_style()}
      />
      <input
        id={@to_input_id}
        data-pui="range-end-value"
        type="hidden"
        name={@to_name}
        value={@to_value || ""}
        aria-hidden="true"
        style={DatePicker.hidden_input_style()}
      />

      <button
        id={@trigger_id}
        data-pui="date-picker-trigger"
        type="button"
        aria-haspopup="dialog"
        aria-expanded="false"
        aria-controls={@popup_id}
        aria-invalid={if @errors != [], do: "true"}
        data-empty={is_nil(DatePicker.format_range_label(@from_value, @to_value))}
        class={DatePicker.trigger_classes(@class)}
      >
        <span class="flex min-w-0 flex-1 items-center gap-2 overflow-hidden">
          <.icon name="hero-calendar" class="size-4 shrink-0 opacity-70" />
          <span
            data-pui="date-picker-label"
            data-placeholder={@placeholder}
            class="block min-w-0 flex-1 truncate text-left"
          >
            {DatePicker.format_range_label(@from_value, @to_value) || @placeholder}
          </span>
        </span>
        <.icon name="hero-chevron-down" class="size-4 shrink-0 opacity-50" />
      </button>

      <div
        id={@popup_id}
        data-pui="date-picker-popup"
        data-grid-cols="7"
        data-grid-navigation="calendar"
        data-focus-date={focus_date("range", nil, @from_value, @to_value)}
        role="listbox"
        tabindex="-1"
        aria-label="Date range calendar"
        aria-hidden="true"
        data-side="bottom"
        data-floating-strategy="absolute"
        data-reference-hidden="false"
        class={DatePicker.content_classes(@content_class)}
      >
        <div class="flex flex-col gap-2 p-1.5 sm:flex-row sm:gap-2">
          <.month_grid
            :for={month <- @months}
            month={month}
            mode="range"
            from_input_id={@from_input_id}
            to_input_id={@to_input_id}
            picker_id={@id}
            trigger_id={@trigger_id}
            from_value={@from_value}
            to_value={@to_value}
            selectable_month={@selectable_month}
            min={@min}
            max={@max}
            number_of_months={@number_of_months}
            show_prev?={month.offset == 0}
            show_next?={month.offset == @number_of_months - 1}
            can_navigate_prev?={
              month.offset == 0 and
                can_navigate?(@visible_month, -1, @min, @max, @number_of_months)
            }
            can_navigate_next?={
              month.offset == @number_of_months - 1 and
                can_navigate?(@visible_month, 1, @min, @max, @number_of_months)
            }
            myself={@myself}
          />
        </div>
        <div :if={@footer != []} class="border-t border-border p-2">
          {render_slot(@footer)}
        </div>
      </div>
    </div>
    """
  end

  attr :month, :map, required: true
  attr :mode, :string, required: true
  attr :input_id, :string, default: nil
  attr :from_input_id, :string, default: nil
  attr :to_input_id, :string, default: nil
  attr :picker_id, :string, required: true
  attr :from_value, :string, default: nil
  attr :to_value, :string, default: nil
  attr :selectable_month, :boolean, default: true
  attr :min, :string, default: nil
  attr :max, :string, default: nil
  attr :number_of_months, :integer, default: 1
  attr :show_prev?, :boolean, default: false
  attr :show_next?, :boolean, default: false
  attr :can_navigate_prev?, :boolean, default: false
  attr :can_navigate_next?, :boolean, default: false
  attr :trigger_id, :string, required: true
  attr :myself, :any, required: true

  defp month_grid(assigns) do
    ~H"""
    <section class="min-w-0 flex-1 space-y-1.5 sm:min-w-56">
      <.month_header
        month={@month}
        selectable_month={@selectable_month}
        min={@min}
        max={@max}
        number_of_months={@number_of_months}
        show_prev?={@show_prev?}
        show_next?={@show_next?}
        can_navigate_prev?={@can_navigate_prev?}
        can_navigate_next?={@can_navigate_next?}
        myself={@myself}
      />

      <div class="grid grid-cols-7 gap-0 text-center text-[0.65rem] font-medium text-muted-foreground">
        <span
          :for={weekday <- ~w(Su Mo Tu We Th Fr Sa)}
          class="inline-flex h-6 items-center justify-center"
        >
          {weekday}
        </span>
      </div>

      <div class="grid grid-cols-7 gap-0">
        <button
          :for={day <- @month.days}
          id={day.id}
          type="button"
          role="option"
          tabindex="-1"
          data-pui="day"
          data-date={day.value}
          data-month-offset={to_string(@month.offset)}
          data-outside-month={to_string(day.outside_month?)}
          aria-selected={to_string(day.selected?)}
          aria-disabled={to_string(day.disabled?)}
          aria-current={if day.today?, do: "date", else: "false"}
          disabled={day.disabled?}
          phx-click={if day.disabled?, do: nil, else: day_click_js(assigns, day)}
          class={day_button_classes(day)}
        >
          <span
            :if={show_range_background?(day)}
            aria-hidden="true"
            class={day_range_background_classes(day)}
          >
          </span>
          <span class={day_label_classes(day)}>{day.label}</span>
        </button>
      </div>
    </section>
    """
  end

  attr :month, :map, required: true
  attr :selectable_month, :boolean, default: true
  attr :min, :string, default: nil
  attr :max, :string, default: nil
  attr :number_of_months, :integer, default: 1
  attr :show_prev?, :boolean, default: false
  attr :show_next?, :boolean, default: false
  attr :can_navigate_prev?, :boolean, default: false
  attr :can_navigate_next?, :boolean, default: false
  attr :myself, :any, required: true

  defp month_header(assigns) do
    ~H"""
    <div class="flex items-center gap-1.5">
      <button
        :if={@show_prev?}
        type="button"
        phx-click={JS.push("navigate", target: @myself, value: %{direction: "prev"})}
        data-pui="calendar-prev"
        class={DatePicker.nav_button_classes()}
        aria-label="Go to previous month"
        disabled={!@can_navigate_prev?}
      >
        <.icon name="hero-chevron-left" class="size-4" />
      </button>
      <span :if={!@show_prev?} class="size-7 shrink-0" aria-hidden="true"></span>

      <div class="flex min-w-0 flex-1 items-center justify-center gap-1.5">
        <%= if @selectable_month do %>
          <select
            id={"#{@month.picker_id}-month-select-#{@month.offset}"}
            data-pui="calendar-month-select"
            data-offset={@month.offset}
            aria-label="Select month"
            class={[DatePicker.header_select_classes(), "min-w-24"]}
          >
            <option
              :for={option <- month_options(@month, @min, @max, @number_of_months)}
              value={option.value}
              selected={option.value == @month.month}
              disabled={option.disabled?}
            >
              {option.label}
            </option>
          </select>

          <select
            id={"#{@month.picker_id}-year-select-#{@month.offset}"}
            data-pui="calendar-year-select"
            data-offset={@month.offset}
            aria-label="Select year"
            class={[DatePicker.header_select_classes(), "min-w-20"]}
          >
            <option
              :for={option <- year_options(@month, @min, @max, @number_of_months)}
              value={option.value}
              selected={option.value == @month.year}
              disabled={option.disabled?}
            >
              {option.label}
            </option>
          </select>
        <% else %>
          <p class="text-sm font-medium">{@month.label}</p>
        <% end %>
      </div>

      <button
        :if={@show_next?}
        type="button"
        phx-click={JS.push("navigate", target: @myself, value: %{direction: "next"})}
        data-pui="calendar-next"
        class={DatePicker.nav_button_classes()}
        aria-label="Go to next month"
        disabled={!@can_navigate_next?}
      >
        <.icon name="hero-chevron-right" class="size-4" />
      </button>
      <span :if={!@show_next?} class="size-7 shrink-0" aria-hidden="true"></span>
    </div>
    """
  end

  defp day_click_js(
         %{mode: "single", input_id: input_id, picker_id: picker_id, myself: myself},
         day
       ) do
    JS.set_attribute({"value", day.value}, to: "##{input_id}")
    |> JS.dispatch("pui:popover-close", to: "##{picker_id}")
    |> JS.dispatch("pui:date-picker-sync", to: "##{picker_id}", detail: %{input: input_id})
    |> JS.push("select", target: myself, value: %{date: day.value})
  end

  defp day_click_js(
         %{
           mode: "range",
           from_input_id: from_input_id,
           to_input_id: to_input_id,
           picker_id: picker_id,
           myself: myself,
           from_value: from_value,
           to_value: to_value
         },
         day
       ) do
    {next_from, next_to} = DatePicker.next_range_selection(from_value, to_value, day.value)

    js =
      JS.set_attribute({"value", next_from || ""}, to: "##{from_input_id}")
      |> JS.set_attribute({"value", next_to || ""}, to: "##{to_input_id}")

    if DatePicker.selection_completes_range?(from_value, to_value, day.value) do
      js
      |> JS.dispatch("pui:popover-close", to: "##{picker_id}")
      |> JS.dispatch("pui:date-picker-sync", to: "##{picker_id}", detail: %{input: from_input_id})
      |> JS.push("select", target: myself, value: %{from: next_from || "", to: next_to || ""})
    else
      js
      |> JS.dispatch("pui:date-picker-sync", to: "##{picker_id}", detail: %{input: from_input_id})
      |> JS.push("select", target: myself, value: %{from: next_from || "", to: next_to || ""})
    end
  end

  defp day_button_classes(day) do
    [
      "group relative inline-flex h-7 w-full items-center justify-center p-0 outline-none",
      day.disabled? && "cursor-not-allowed",
      (not day.disabled? and not day.selected? and not day.in_range?) &&
        "hover:text-accent-foreground"
    ]
  end

  defp day_label_classes(day) do
    [
      "relative z-10 inline-flex size-7 items-center justify-center rounded-md text-[0.8125rem] transition-colors",
      "group-focus-visible:border-ring group-focus-visible:ring-ring/50 group-focus-visible:ring-[3px]",
      (not day.disabled? and day.selected?) &&
        "bg-primary font-medium text-primary-foreground hover:bg-primary/90",
      (not day.disabled? and not day.selected? and day.in_range?) &&
        "text-accent-foreground hover:bg-accent/35",
      (not day.disabled? and not day.selected? and not day.in_range?) &&
        "hover:bg-accent hover:text-accent-foreground",
      day.disabled? && "text-muted-foreground opacity-35",
      day.outside_month? && "text-muted-foreground opacity-60",
      (not day.outside_month? and not day.selected? and not day.disabled?) && "text-foreground",
      (day.today? and not day.selected? and not day.disabled?) && "ring-1 ring-ring/60"
    ]
  end

  defp show_range_background?(day), do: day.in_range? or day.range_start? or day.range_end?

  defp day_range_background_classes(day) do
    [
      "absolute inset-y-0 bg-accent/75",
      day.in_range? && "inset-x-0",
      (day.range_start? and not day.range_end?) && "left-1/2 right-0",
      (day.range_end? and not day.range_start?) && "left-0 right-1/2"
    ]
  end

  defp build_months(
         picker_id,
         mode,
         visible_month,
         number_of_months,
         value,
         from_value,
         to_value,
         min,
         max
       ) do
    visible_month = DatePicker.normalize_date!(visible_month)

    Enum.map(0..(number_of_months - 1), fn offset ->
      month_start =
        DatePicker.shift_month(Date.to_iso8601(visible_month), offset)
        |> DatePicker.normalize_date!()

      %{
        picker_id: picker_id,
        offset: offset,
        label: Calendar.strftime(month_start, "%B %Y"),
        month: month_start.month,
        year: month_start.year,
        value: Date.to_iso8601(month_start),
        days:
          build_days(picker_id, offset, mode, month_start, value, from_value, to_value, min, max)
      }
    end)
  end

  defp build_days(picker_id, offset, mode, month_start, value, from_value, to_value, min, max) do
    start_date =
      Date.add(month_start, 1 - Date.day_of_week(month_start, :sunday))

    Enum.map(0..41, fn index ->
      date = Date.add(start_date, index)
      value_iso = Date.to_iso8601(date)
      outside_month? = date.month != month_start.month or date.year != month_start.year
      disabled? = not DatePicker.within_bounds?(value_iso, min, max)
      range_start? = not disabled? and range_start?(mode, value_iso, from_value, to_value)
      range_end? = not disabled? and range_end?(mode, value_iso, from_value, to_value)
      selected? = not disabled? and selected?(mode, value_iso, value, from_value, to_value)
      in_range? = not disabled? and in_range?(mode, value_iso, from_value, to_value)
      today? = Date.compare(date, Date.utc_today()) == :eq

      %{
        id: "#{picker_id}-month-#{offset}-day-#{value_iso}",
        value: value_iso,
        label: date.day,
        outside_month?: outside_month?,
        disabled?: disabled?,
        range_start?: range_start?,
        range_end?: range_end?,
        selected?: selected?,
        in_range?: in_range?,
        today?: today?
      }
    end)
  end

  defp selected?("single", value_iso, value, _from_value, _to_value), do: value_iso == value

  defp selected?("range", value_iso, _value, from_value, to_value),
    do: value_iso in [from_value, to_value]

  defp range_start?("range", value_iso, from_value, to_value),
    do: is_binary(to_value) and value_iso == from_value

  defp range_start?("single", _value_iso, _from_value, _to_value), do: false

  defp range_end?("range", value_iso, _from_value, to_value),
    do: is_binary(to_value) and value_iso == to_value

  defp range_end?("single", _value_iso, _from_value, _to_value), do: false

  defp in_range?("single", _value_iso, _from_value, _to_value), do: false

  defp in_range?("range", value_iso, from_value, to_value)
       when is_binary(from_value) and is_binary(to_value) do
    Date.compare(DatePicker.normalize_date!(value_iso), DatePicker.normalize_date!(from_value)) ==
      :gt and
      Date.compare(DatePicker.normalize_date!(value_iso), DatePicker.normalize_date!(to_value)) ==
        :lt
  end

  defp in_range?("range", _value_iso, _from_value, _to_value), do: false

  defp resolve_visible_month("single", default_month, value, _from_value, _to_value) do
    DatePicker.resolve_visible_month(default_month, [value])
  end

  defp resolve_visible_month("range", default_month, _value, from_value, to_value) do
    DatePicker.resolve_visible_month(default_month, [to_value, from_value])
  end

  defp maybe_preserve_visible_month(
         mode,
         current_visible_month,
         default_month,
         value,
         from_value,
         to_value,
         number_of_months
       ) do
    resolved_visible_month =
      resolve_visible_month(mode, default_month, value, from_value, to_value)

    focus_value = focus_value(mode, value, from_value, to_value)

    if DatePicker.visible_window_contains?(current_visible_month, focus_value, number_of_months) do
      current_visible_month
    else
      resolved_visible_month
    end
  end

  defp focus_date("single", value, _from_value, _to_value),
    do: value || Date.utc_today() |> Date.to_iso8601()

  defp focus_date("range", _value, from_value, to_value),
    do: to_value || from_value || Date.utc_today() |> Date.to_iso8601()

  defp focus_value("single", value, _from_value, _to_value), do: value
  defp focus_value("range", _value, from_value, to_value), do: to_value || from_value

  defp assign_calendar(socket, overrides) do
    overrides = Map.new(overrides)

    visible_month =
      Map.get(overrides, :visible_month, socket.assigns.visible_month)
      |> DatePicker.clamp_visible_month(
        socket.assigns.min,
        socket.assigns.max,
        socket.assigns.number_of_months
      )

    value = Map.get(overrides, :value, socket.assigns.value)
    from_value = Map.get(overrides, :from_value, socket.assigns.from_value)
    to_value = Map.get(overrides, :to_value, socket.assigns.to_value)

    assign(
      socket,
      value: value,
      from_value: from_value,
      to_value: to_value,
      visible_month: visible_month,
      months:
        build_months(
          socket.assigns.picker_id,
          socket.assigns.mode,
          visible_month,
          socket.assigns.number_of_months,
          value,
          from_value,
          to_value,
          socket.assigns.min,
          socket.assigns.max
        )
    )
  end

  defp can_navigate?(visible_month, offset, min, max, number_of_months) do
    next_visible_month = DatePicker.shift_month(visible_month, offset)
    DatePicker.visible_month_allowed?(next_visible_month, min, max, number_of_months)
  end

  defp month_options(month, min, max, number_of_months) do
    Enum.map(1..12, fn month_number ->
      candidate_visible_month =
        Date.new!(month.year, month_number, 1)
        |> Date.to_iso8601()
        |> DatePicker.shift_month(-month.offset)

      %{
        label: DatePicker.month_name(month_number),
        value: month_number,
        disabled?:
          not DatePicker.visible_month_allowed?(
            candidate_visible_month,
            min,
            max,
            number_of_months
          )
      }
    end)
  end

  defp year_options(month, min, max, number_of_months) do
    {first_year, last_year} = year_bounds(month, min, max, number_of_months)

    Enum.map(first_year..last_year, fn year ->
      candidate_visible_month =
        Date.new!(year, month.month, 1)
        |> Date.to_iso8601()
        |> DatePicker.shift_month(-month.offset)

      %{
        label: year,
        value: year,
        disabled?:
          not DatePicker.visible_month_allowed?(
            candidate_visible_month,
            min,
            max,
            number_of_months
          )
      }
    end)
  end

  defp year_bounds(month, min, max, number_of_months) do
    current_year = month.year

    min_year =
      min
      |> visible_bound_for_offset(month.offset)
      |> case do
        nil -> current_year - 100
        value -> DatePicker.normalize_date!(value).year
      end

    max_year =
      max
      |> visible_bound_for_offset(month.offset, number_of_months)
      |> case do
        nil -> current_year + 20
        value -> DatePicker.normalize_date!(value).year
      end

    {min_year, max(max_year, min_year)}
  end

  defp visible_bound_for_offset(value, offset, number_of_months \\ 1)
  defp visible_bound_for_offset(nil, _offset, _number_of_months), do: nil

  defp visible_bound_for_offset(value, offset, number_of_months) do
    value
    |> DatePicker.normalize_date!()
    |> Date.beginning_of_month()
    |> Date.to_iso8601()
    |> DatePicker.shift_month(offset - (number_of_months - 1))
  end

  defp range_values_within_bounds?(values, min, max) do
    Enum.all?(values, fn
      nil -> true
      value -> DatePicker.within_bounds?(value, min, max)
    end)
  end
end
