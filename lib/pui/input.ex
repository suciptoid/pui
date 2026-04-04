defmodule PUI.Input do
  @moduledoc """
  Form controls for text inputs, checkboxes, radios, switches, labels, and textareas.

  `PUI.Input` collects the core form primitives used across PUI. The text-based
  controls support direct binding to `Phoenix.HTML.FormField` values, and all
  form controls can render validation feedback through the `errors` attribute.

  ## Field-based forms

      <.form for={@form} phx-change="validate">
        <.input field={@form[:email]} type="email" label="Email" />
        <.textarea field={@form[:notes]} label="Notes" rows="5" />
      </.form>

  When `field` is provided, the component derives its `id`, `name`, and `value`
  from the form field. Errors are shown only after
  `Phoenix.Component.used_input?/1` marks the field as used.

  ## Manual errors

      <.checkbox
        id="terms"
        name="terms"
        label="I agree to the terms"
        errors={["Please accept the terms."]}
      />

      <.switch
        id="notifications"
        name="notifications"
        label="Enable notifications"
        errors={["Turn this on before continuing."]}
      />

  ## Included components

  - `input/1` for single-line HTML inputs
  - `textarea/1` for multi-line text
  - `checkbox/1` for boolean choices
  - `radio/1` for single-choice groups
  - `switch/1` for toggle-style boolean controls
  - `label/1` for standalone labels
  """

  use Phoenix.Component
  import PUI.Components, only: [field_error: 1]

  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :type, :string, default: "text"
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list,
    default: [],
    doc: "a list of error strings to display below the input"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
              multiple pattern placeholder readonly required rows size step name value)

  @doc """
  Renders a styled single-line HTML input.

  Use `field={@form[:name]}` to bind the input to a Phoenix form field, or pass
  `name`, `value`, and `errors` directly for manual control.

  ## Examples

      <.input type="email" name="email" label="Email" placeholder="you@example.com" />

      <.input field={@form[:email]} type="email" label="Email" />

      <.input
        name="company"
        label="Company"
        errors={["Please enter a company name."]}
      />
  """
  def input(%{label: label} = assigns) when label not in ["", nil] do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <div class="flex w-full flex-col gap-3 pb-3">
      <.label for={@id}>{@label}</.label>
      <div>
        <.input id={@id} class={@class} type={@type} {@rest} />
        <.field_error errors={@errors} />
      </div>
    </div>
    """
  end

  def input(assigns) do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <input
      id={@id}
      type={@type}
      class={[
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        @class
      ]}
      {@rest}
    />
    <.field_error errors={@errors} />
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(for)
  slot :inner_block

  @doc """
  Renders a standalone form label.

  ## Examples

      <.label for="email">Email</.label>
  """
  def label(assigns) do
    ~H"""
    <label
      class={[
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        "peer-has-disabled:opacity-50 peer-has-disabled:cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </label>
    """
  end

  attr :id, :any, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list,
    default: [],
    doc: "a list of error strings to display below the checkbox"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
              multiple pattern placeholder readonly required rows size step checked name value)

  slot :inner_block

  @doc """
  Renders a checkbox control.

  Use `label` for the default checkbox-plus-label layout, or omit it when you
  need complete control over the surrounding markup. Validation messages can be
  supplied with the `errors` attribute.

  ## Examples

      <.checkbox id="terms" name="terms" label="I agree to the terms" />

      <.checkbox
        id="terms"
        name="terms"
        label="I agree to the terms"
        errors={["Please accept the terms."]}
      />
  """
  def checkbox(%{label: label} = assigns) when label != nil do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <div>
      <label class="inline-flex items-center cursor-pointer">
        <.checkbox id={@id} class={@class} {@rest} />
        <span class="text-sm text-foreground ms-3">
          {@label}
        </span>
      </label>
      <.field_error errors={@errors} />
    </div>
    """
  end

  def checkbox(assigns) do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <input
      id={@id}
      type="checkbox"
      class={[
        "relative size-4 shrink-0 appearance-none rounded-[4px] border border-input shadow-xs outline-none cursor-pointer",
        "before:content-[''] before:absolute before:top-0 before:left-[2px] before:w-[calc(100%-2px)] before:h-[calc(100%-2px)] before:bg-current before:opacity-0",
        "before:[clip-path:polygon(28%_100%,28%_85%,50%_85%,50%_15%,65%_15%,65%_100%)] before:rotate-45 before:origin-center",
        "before:transition-all before:duration-100",
        "focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:border-ring",
        "checked:bg-primary checked:text-primary-foreground checked:border-primary",
        "checked:before:opacity-100",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "dark:bg-input/30 dark:checked:bg-primary",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        @class
      ]}
      {@rest}
    />
    <.field_error errors={@errors} />
    """
  end

  attr :id, :any, default: nil
  attr :rest, :global, include: ~w(checked name value)
  attr :class, :string, default: ""

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  @doc """
  Renders a radio input for a radio group.

  Radios typically share a `name` and differ by `value`. When validation fails,
  pass `errors` to render a message below the radio control.

  ## Examples

      <label class="flex items-center gap-3">
        <.radio id="plan-pro" name="plan" value="pro" />
        <span>Pro</span>
      </label>

      <div class="space-y-2">
        <label class="flex items-center gap-3">
          <.radio
            id="plan-starter"
            name="plan"
            value="starter"
            errors={["Please choose a plan."]}
          />
          <span>Starter</span>
        </label>
      </div>
  """
  def radio(assigns) do
    assigns = map_field(assigns)
    # Radio inputs do not render validation errors inline; ignore any field errors here.
    assigns = assign(assigns, :errors, [])

    ~H"""
    <input
      id={@id}
      type="radio"
      class={[
        "border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 appearance-none relative after:content-[''] after:absolute after:top-1/2 after:left-1/2 after:size-2 after:-translate-x-1/2 after:-translate-y-1/2 after:rounded-full after:bg-primary after:scale-0 checked:after:scale-100 after:transition-transform",
        @class
      ]}
      {@rest}
    />
    """
  end

  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list,
    default: [],
    doc: "a list of error strings to display below the switch"

  attr :rest, :global,
    include: ~w(accept  capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step name value)

  @doc """
  Renders a switch-style boolean control.

  `switch/1` shares the same `field` and `errors` conventions as the other form
  controls, while presenting the boolean input as a compact toggle.

  ## Examples

      <.switch id="notifications" name="notifications" label="Enable notifications" />

      <.switch
        id="notifications"
        name="notifications"
        label="Enable notifications"
        errors={["Turn this on before continuing."]}
      />
  """
  def switch(%{label: label} = assigns) when label != nil do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <div>
      <label class="inline-flex items-center cursor-pointer">
        <.switch id={@id} class={@class} {@rest} />
        <span class="text-sm text-foreground ms-3">
          {@label}
        </span>
      </label>
      <.field_error errors={@errors} />
    </div>
    """
  end

  def switch(assigns) do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <input
      id={@id}
      type="checkbox"
      role="switch"
      class={[
        "appearance-none checked:bg-primary bg-input focus-visible:border-ring focus-visible:ring-ring/50 dark:bg-input/80 inline-flex h-[1.15rem] w-8 shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 relative after:content-[''] after:absolute after:bg-background dark:after:bg-foreground dark:checked:after:bg-primary-foreground after:pointer-events-none after:block after:size-4 after:rounded-full after:ring-0 after:transition-transform checked:after:translate-x-[calc(100%-2px)] after:translate-x-0",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        @class
      ]}
      {@rest}
    />
    <.field_error errors={@errors} />
    """
  end

  @doc """
  Renders a multi-line textarea.

  `textarea/1` supports manual values and errors, or it can bind to a Phoenix
  form field to inherit the field's `id`, `name`, `value`, and validation state.

  ## Examples

      <.textarea label="Notes" name="notes" rows="5" />

      <.textarea field={@form[:notes]} label="Notes" rows="5" />

      <.textarea
        name="notes"
        label="Notes"
        errors={["Please add a short note."]}
      />
  """
  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list,
    default: [],
    doc: "a list of error strings to display below the textarea"

  attr :rest, :global,
    include: ~w(accept  capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step name value)

  def textarea(%{label: label} = assigns) when label not in ["", nil] do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <div class="grid w-full items-center gap-3 pb-3">
      <.label for={@id}>{@label}</.label>
      <div>
        <.textarea id={@id} class={@class} {@rest} />
        <.field_error errors={@errors} />
      </div>
    </div>
    """
  end

  def textarea(assigns) do
    assigns = map_field(assigns)

    assigns =
      if assigns.errors != [],
        do: update(assigns, :rest, &Map.put(&1, :"aria-invalid", "true")),
        else: assigns

    ~H"""
    <textarea
      id={@id}
      class={[
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        @class
      ]}
      {@rest}
    >{@rest[:value]}</textarea>
    <.field_error errors={@errors} />
    """
  end

  def map_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    rest =
      assigns
      |> Map.get(:rest, %{})
      |> Map.put(:name, field.name)
      |> then(fn rest ->
        type = Map.get(rest, :type, "text")
        rest |> Map.put(:value, Phoenix.HTML.Form.normalize_value(type, field.value))
      end)

    assigns
    |> assign(:id, assigns.id || field.id)
    |> assign(:field, nil)
    |> assign(:errors, Enum.map(errors, &PUI.Components.translate_error/1))
    |> assign(:rest, rest)
  end

  def map_field(assigns) do
    assigns
  end

  def generate_id(prefix \\ "input"), do: "#{prefix}_#{System.unique_integer([:positive])}"
end
