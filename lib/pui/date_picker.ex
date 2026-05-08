defmodule PUI.DatePicker do
  @moduledoc """
  Date picker components built from a trigger button and a popover calendar.

  The calendar grid is rendered server-side by a LiveComponent, while the
  existing popover hook handles positioning and open/close behavior.

  ## Examples

      <.date_picker
        id="published-on"
        name="published_on"
        label="Publish date"
        min={~D[2026-04-10]}
        max={~D[2026-04-30]}
      />

      <.range_picker
        id="trip-range"
        from_name="trip_start"
        to_name="trip_end"
        label="Trip range"
      >
        <:footer>
          <input
            type="time"
            class="border-input h-9 rounded-md border bg-transparent px-3 text-sm"
          />
        </:footer>
      </.range_picker>

  ## Common attributes

  Both pickers support:

  | Name | Type | Default | Description |
  |------|------|---------|-------------|
  | `id` | `string` | generated | Unique identifier used for the trigger and popup |
  | `default_month` | `Date.t() \| String.t()` | `nil` | Initial month shown when no date is selected |
  | `min` | `Date.t() \| String.t()` | `nil` | Minimum selectable day |
  | `max` | `Date.t() \| String.t()` | `nil` | Maximum selectable day |
  | `selectable_month` | `boolean` | `true` | Shows native month and year selects in the calendar header |
  | `week_start` | `:monday \| :sunday` | `:monday` | First day of the week in the calendar grid |
  | `show_overlap` | `boolean` | `true` | Shows days from adjacent months in the calendar grid |
  | `placeholder` | `string` | picker-specific | Placeholder text shown before a value is selected |
  | `label` | `string` | `nil` | Optional field label |
  | `class` | `string` | `"w-full"` | Additional trigger classes |
  | `content_class` | `string` | `""` | Additional popup classes |
  | `errors` | `list` | `[]` | Error messages rendered below the picker |
  | `show_errors` | `boolean` | `true` | Controls error rendering |

  ## Slots

  | Name | Required | Description |
  |------|----------|-------------|
  | `footer` | — | Optional footer content rendered below the calendar grid |
  """

  use Phoenix.Component

  import PUI.Components, only: [field_error: 1]
  import PUI.Input, only: [label: 1]

  alias PUI.DatePickerComponent

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :default_month, :any, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :selectable_month, :boolean, default: true
  attr :week_start, :atom, values: [:monday, :sunday], default: :monday
  attr :show_overlap, :boolean, default: true
  attr :placeholder, :string, default: "Pick a date"
  attr :class, :string, default: "w-full"
  attr :content_class, :string, default: ""
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:published_on]"

  attr :errors, :list, default: []
  attr :show_errors, :boolean, default: true
  slot :footer

  def date_picker(assigns) do
    assigns =
      assigns
      |> map_date_field()
      |> ensure_picker_id("date_picker")

    assigns =
      assign(assigns,
        value: normalize_date_value(assigns.value),
        default_month: normalize_date_value(assigns.default_month),
        min: normalize_date_value(assigns.min),
        max: normalize_date_value(assigns.max),
        input_id: "#{assigns.id}-input",
        trigger_id: "#{assigns.id}-trigger",
        popup_id: "#{assigns.id}-popover"
      )

    ~H"""
    <div class="flex w-full flex-col gap-3">
      <.label :if={present?(@label)} for={@input_id}>{@label}</.label>
      <div>
        <.live_component
          module={DatePickerComponent}
          id={@id}
          mode="single"
          name={@name}
          value={@value}
          default_month={@default_month}
          min={@min}
          max={@max}
          selectable_month={@selectable_month}
          week_start={@week_start}
          show_overlap={@show_overlap}
          placeholder={@placeholder}
          class={@class}
          content_class={@content_class}
          errors={@errors}
          input_id={@input_id}
          trigger_id={@trigger_id}
          popup_id={@popup_id}
          footer={@footer}
        />
        <.field_error :if={@show_errors} errors={@errors} />
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :from_name, :string, default: nil
  attr :to_name, :string, default: nil
  attr :from_value, :any, default: nil
  attr :to_value, :any, default: nil
  attr :default_month, :any, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :selectable_month, :boolean, default: true
  attr :week_start, :atom, values: [:monday, :sunday], default: :monday
  attr :show_overlap, :boolean, default: true
  attr :number_of_months, :integer, default: 2
  attr :placeholder, :string, default: "Pick a date range"
  attr :class, :string, default: "w-full"
  attr :content_class, :string, default: ""
  attr :label, :string, default: nil

  attr :from_field, Phoenix.HTML.FormField, default: nil
  attr :to_field, Phoenix.HTML.FormField, default: nil
  attr :errors, :list, default: []
  attr :show_errors, :boolean, default: true
  slot :footer

  def range_picker(assigns) do
    assigns =
      assigns
      |> map_range_fields()
      |> ensure_picker_id("range_picker")

    assigns =
      assign(assigns,
        from_value: normalize_date_value(assigns.from_value),
        to_value: normalize_date_value(assigns.to_value),
        default_month: normalize_date_value(assigns.default_month),
        min: normalize_date_value(assigns.min),
        max: normalize_date_value(assigns.max),
        from_input_id: "#{assigns.id}-from-input",
        to_input_id: "#{assigns.id}-to-input",
        trigger_id: "#{assigns.id}-trigger",
        popup_id: "#{assigns.id}-popover"
      )

    ~H"""
    <div class="flex w-full flex-col gap-3">
      <.label :if={present?(@label)} for={@from_input_id}>{@label}</.label>
      <div>
        <.live_component
          module={DatePickerComponent}
          id={@id}
          mode="range"
          from_name={@from_name}
          to_name={@to_name}
          from_value={@from_value}
          to_value={@to_value}
          default_month={@default_month}
          min={@min}
          max={@max}
          selectable_month={@selectable_month}
          week_start={@week_start}
          show_overlap={@show_overlap}
          number_of_months={@number_of_months}
          placeholder={@placeholder}
          class={@class}
          content_class={@content_class}
          errors={@errors}
          from_input_id={@from_input_id}
          to_input_id={@to_input_id}
          trigger_id={@trigger_id}
          popup_id={@popup_id}
          footer={@footer}
        />
        <.field_error :if={@show_errors} errors={@errors} />
      </div>
    </div>
    """
  end

  @doc false
  def normalize_date_value(nil), do: nil
  def normalize_date_value(""), do: nil
  def normalize_date_value(%Date{} = date), do: Date.to_iso8601(date)

  def normalize_date_value(%NaiveDateTime{} = value),
    do: value |> NaiveDateTime.to_date() |> Date.to_iso8601()

  def normalize_date_value(%DateTime{} = value),
    do: value |> DateTime.to_date() |> Date.to_iso8601()

  def normalize_date_value(value) when is_binary(value) do
    value = String.trim(value)

    cond do
      value == "" ->
        nil

      match?({:ok, _date}, Date.from_iso8601(value)) ->
        value

      match?({:ok, _value}, NaiveDateTime.from_iso8601(value)) ->
        value |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date() |> Date.to_iso8601()

      match?({:ok, _value, _offset}, DateTime.from_iso8601(value)) ->
        value
        |> DateTime.from_iso8601()
        |> then(fn {:ok, datetime, _offset} -> DateTime.to_date(datetime) end)
        |> Date.to_iso8601()

      true ->
        nil
    end
  end

  @doc false
  def normalize_date!(value) do
    value
    |> normalize_date_value()
    |> then(fn
      nil -> raise ArgumentError, "expected ISO date value"
      iso -> Date.from_iso8601!(iso)
    end)
  end

  @doc false
  def format_date_label(nil), do: nil
  def format_date_label(value), do: value |> normalize_date!() |> Calendar.strftime("%b %d, %Y")

  @doc false
  def format_range_label(nil, nil), do: nil
  def format_range_label(from_value, nil), do: format_date_label(from_value)

  def format_range_label(from_value, to_value) do
    [format_date_label(from_value), format_date_label(to_value)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" - ")
  end

  @doc false
  def resolve_visible_month(default_month, values) do
    default_month =
      default_month
      |> normalize_date_value()
      |> case do
        nil -> nil
        iso -> iso |> normalize_date!() |> Date.beginning_of_month() |> Date.to_iso8601()
      end

    selected_month =
      values
      |> Enum.map(&normalize_date_value/1)
      |> Enum.find(& &1)
      |> case do
        nil -> nil
        iso -> iso |> normalize_date!() |> Date.beginning_of_month() |> Date.to_iso8601()
      end

    selected_month || default_month ||
      Date.utc_today() |> Date.beginning_of_month() |> Date.to_iso8601()
  end

  @doc false
  def shift_month(value, offset) do
    date = normalize_date!(value)
    total = date.year * 12 + date.month - 1 + offset
    year = div(total, 12)
    month = rem(total, 12) + 1
    Date.new!(year, month, 1) |> Date.to_iso8601()
  end

  @doc false
  def visible_month_for_offset(value, offset), do: shift_month(value, offset)

  @doc false
  def visible_window_contains?(visible_month, value, number_of_months) do
    visible_month = normalize_date_value(visible_month)
    value = normalize_date_value(value)

    cond do
      is_nil(visible_month) or is_nil(value) ->
        false

      true ->
        first_visible_day =
          visible_month
          |> normalize_date!()
          |> Date.beginning_of_month()

        last_visible_day =
          visible_month
          |> shift_month(number_of_months - 1)
          |> normalize_date!()
          |> Date.end_of_month()

        date = normalize_date!(value)

        Date.compare(date, first_visible_day) in [:eq, :gt] and
          Date.compare(date, last_visible_day) in [:eq, :lt]
    end
  end

  @doc false
  def clamp_visible_month(value, min, max, number_of_months) do
    visible_month =
      value
      |> normalize_date!()
      |> Date.beginning_of_month()
      |> Date.to_iso8601()

    {lower_bound, upper_bound} = visible_month_bounds(min, max, number_of_months)

    cond do
      lower_bound &&
          Date.compare(normalize_date!(visible_month), normalize_date!(lower_bound)) == :lt ->
        lower_bound

      upper_bound &&
          Date.compare(normalize_date!(visible_month), normalize_date!(upper_bound)) == :gt ->
        upper_bound

      true ->
        visible_month
    end
  end

  @doc false
  def visible_month_allowed?(value, min, max, number_of_months) do
    visible_month =
      value
      |> normalize_date!()
      |> Date.beginning_of_month()
      |> Date.to_iso8601()

    visible_month == clamp_visible_month(visible_month, min, max, number_of_months)
  end

  @doc false
  def set_visible_month(year, month, offset, min, max, number_of_months) do
    Date.new!(year, month, 1)
    |> Date.to_iso8601()
    |> shift_month(-offset)
    |> clamp_visible_month(min, max, number_of_months)
  end

  @doc false
  def within_bounds?(nil, _min, _max), do: false

  @doc false
  def within_bounds?(value, min, max) do
    date = normalize_date!(value)
    min = normalize_date_value(min)
    max = normalize_date_value(max)

    after_min? =
      is_nil(min) or Date.compare(date, normalize_date!(min)) in [:eq, :gt]

    before_max? =
      is_nil(max) or Date.compare(date, normalize_date!(max)) in [:eq, :lt]

    after_min? and before_max?
  end

  @doc false
  def month_name(month) when month in 1..12 do
    ~w(January February March April May June July August September October November December)
    |> Enum.at(month - 1)
  end

  @doc false
  def next_range_selection(from_value, to_value, date_value) do
    from_value = normalize_date_value(from_value)
    to_value = normalize_date_value(to_value)
    date_value = normalize_date_value(date_value)

    cond do
      is_nil(from_value) or not is_nil(to_value) ->
        {date_value, nil}

      Date.compare(normalize_date!(date_value), normalize_date!(from_value)) in [:lt, :eq] ->
        {date_value, from_value}

      true ->
        {from_value, date_value}
    end
  end

  @doc false
  def selection_completes_range?(from_value, to_value, date_value) do
    from_value = normalize_date_value(from_value)
    to_value = normalize_date_value(to_value)
    date_value = normalize_date_value(date_value)

    not is_nil(from_value) and
      is_nil(to_value) and
      Date.compare(normalize_date!(date_value), normalize_date!(from_value)) != :eq
  end

  @doc false
  def hidden_input_style do
    "position:absolute;width:0;height:0;overflow:hidden;opacity:0;pointer-events:none;border:0;padding:0;margin:0"
  end

  @doc false
  def trigger_classes(class) do
    [
      "border-input data-[empty=true]:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground",
      "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
      "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
      "dark:bg-input/30 dark:hover:bg-input/50 flex h-9 min-w-0 items-center justify-between gap-2 rounded-md border bg-transparent px-3 py-2 text-sm shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:opacity-50",
      class
    ]
  end

  @doc false
  def content_classes(content_class) do
    [
      "aria-hidden:hidden block overflow-hidden rounded-lg border border-border bg-popover text-popover-foreground",
      "not-aria-hidden:animate-in aria-hidden:animate-out aria-hidden:fade-out-0 not-aria-hidden:fade-in-0 aria-hidden:zoom-out-95 not-aria-hidden:zoom-in-95",
      "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
      "z-50 w-auto min-w-[15rem] origin-top shadow-md data-[reference-hidden=true]:pointer-events-none data-[reference-hidden=true]:invisible data-[side=left]:origin-right data-[side=right]:origin-left data-[side=top]:origin-bottom",
      content_class
    ]
  end

  @doc false
  def nav_button_classes do
    "inline-flex size-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] outline-none disabled:pointer-events-none disabled:opacity-40"
  end

  @doc false
  def header_select_classes do
    "h-8 bg-transparent px-1 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50"
  end

  defp map_date_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:id, assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:value, if(is_nil(assigns.value), do: field.value, else: assigns.value))
    |> assign(:field, nil)
    |> assign(:errors, translate_field_errors(field))
  end

  defp map_date_field(assigns), do: assigns

  defp map_range_fields(assigns) do
    from_field = Map.get(assigns, :from_field)
    to_field = Map.get(assigns, :to_field)

    translated_errors =
      [from_field, to_field]
      |> Enum.flat_map(&translate_field_errors/1)
      |> Enum.uniq()

    assigns
    |> assign(:id, assigns.id || field_id(from_field) || field_id(to_field))
    |> assign(:from_name, assigns.from_name || field_name(from_field))
    |> assign(:to_name, assigns.to_name || field_name(to_field))
    |> assign(
      :from_value,
      if(is_nil(assigns.from_value), do: field_value(from_field), else: assigns.from_value)
    )
    |> assign(
      :to_value,
      if(is_nil(assigns.to_value), do: field_value(to_field), else: assigns.to_value)
    )
    |> assign(:from_field, nil)
    |> assign(:to_field, nil)
    |> assign(:errors, if(translated_errors == [], do: assigns.errors, else: translated_errors))
  end

  defp ensure_picker_id(%{id: nil} = assigns, prefix),
    do: assign(assigns, :id, PUI.Input.generate_id(prefix))

  defp ensure_picker_id(assigns, _prefix), do: assigns

  defp translate_field_errors(%Phoenix.HTML.FormField{} = field) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
    Enum.map(errors, &PUI.Components.translate_error/1)
  end

  defp translate_field_errors(_field), do: []
  defp field_id(%Phoenix.HTML.FormField{id: id}), do: id
  defp field_id(_field), do: nil
  defp field_name(%Phoenix.HTML.FormField{name: name}), do: name
  defp field_name(_field), do: nil
  defp field_value(%Phoenix.HTML.FormField{value: value}), do: value
  defp field_value(_field), do: nil
  defp present?(value), do: value not in [nil, ""]

  defp visible_month_bounds(min, max, number_of_months) do
    lower_bound =
      min
      |> normalize_date_value()
      |> case do
        nil -> nil
        value -> value |> normalize_date!() |> Date.beginning_of_month() |> Date.to_iso8601()
      end

    upper_bound =
      max
      |> normalize_date_value()
      |> case do
        nil ->
          nil

        value ->
          value
          |> normalize_date!()
          |> Date.beginning_of_month()
          |> Date.to_iso8601()
          |> shift_month(-(number_of_months - 1))
      end

    if lower_bound && upper_bound &&
         Date.compare(normalize_date!(upper_bound), normalize_date!(lower_bound)) == :lt do
      {lower_bound, lower_bound}
    else
      {lower_bound, upper_bound}
    end
  end
end
