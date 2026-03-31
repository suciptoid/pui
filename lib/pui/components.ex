defmodule PUI.Components do
  use Phoenix.Component

  attr :min, :float, default: 0.0
  attr :max, :float, default: 100.0
  attr :value, :float, default: 0.0
  attr :class, :string, default: ""

  @doc """
  """
  def progress(assigns) do
    ~H"""
    <div
      role="progressbar"
      aria-valuenow={@value}
      aria-valuemin={@min}
      aria-valuemax={@max}
      class={[
        "bg-primary/20 relative h-2 w-full overflow-hidden rounded-full",
        @class
      ]}
    >
      <div
        style={"transform: translateX(-#{100 - (@value || 0)}%)"}
        class={[
          "bg-primary h-full w-full flex-1 transition-all"
        ]}
      >
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""

  attr :variant, :string,
    values: ["default", "secondary", "destructive", "outline"],
    default: "default"

  slot :inner_block

  def badge(assigns) do
    assigns =
      case assigns[:variant] do
        "default" ->
          assigns
          |> assign(
            :variant_class,
            "border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90"
          )

        "secondary" ->
          assigns
          |> assign(
            :variant_class,
            "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90"
          )

        "destructive" ->
          assigns
          |> assign(
            :variant_class,
            "border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60"
          )

        "outline" ->
          assigns
          |> assign(
            :variant_class,
            "text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground"
          )
      end

    ~H"""
    <span class={[
      "inline-flex items-center justify-center rounded-full border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
      @variant_class,
      @class
    ]}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Renders form field error messages.

  Displays validation errors below form inputs. Renders nothing when `errors` is empty.

  ## Examples

      <.field_error errors={["can't be blank"]} />
      <.field_error errors={["must be at least 3 characters", "is invalid"]} />
      <.field_error errors={[]} />
  """
  attr :errors, :list, default: []

  def field_error(assigns) do
    ~H"""
    <p
      :for={msg <- @errors}
      class="mt-1.5 text-[0.8rem] font-medium text-destructive"
    >
      {msg}
    </p>
    """
  end

  @doc """
  Translates a form error tuple into a human-readable string.

  Error tuples from changesets have the form `{msg, opts}` where `msg` may contain
  interpolation placeholders like `%{count}`.

  ## Examples

      iex> PUI.Components.translate_error({"can't be blank", []})
      "can't be blank"

      iex> PUI.Components.translate_error({"should be at least %{count} character(s)", [count: 3]})
      "should be at least 3 character(s)"
  """
  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
