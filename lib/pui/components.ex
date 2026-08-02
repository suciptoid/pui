defmodule PUI.Components do
  use Phoenix.Component

  attr :min, :float, default: 0.0
  attr :max, :float, default: 100.0
  attr :value, :float, default: 0.0
  attr :label, :string, default: nil, doc: "accessible label for the progressbar"
  attr :aria_labelledby, :string, default: nil, doc: "id of an element labelling the progressbar"

  attr :value_text, :string,
    default: nil,
    doc: "human-readable value text announced by screen readers"

  attr :class, :string, default: ""

  @deprecated "Use PUI.Progress.progress/1 instead."
  def progress(assigns), do: PUI.Progress.progress(assigns)

  attr :class, :string, default: ""

  attr :variant, :string,
    values: ["default", "secondary", "destructive", "outline"],
    default: "default"

  slot :inner_block

  @deprecated "Use PUI.Badge.badge/1 instead."
  def badge(assigns), do: PUI.Badge.badge(assigns)

  @doc """
  Renders form field error messages.

  Displays validation errors below form inputs. Renders nothing when `errors` is empty.
  Each error paragraph is marked with `role="alert"` and `aria-live="polite"` so screen
  readers announce new errors as they appear. A deterministic `id` is generated from
  the `id` attribute (defaulting to `"field-error"`) so callers can wire the input's
  `aria-errormessage` to it.

  ## Examples

      <.field_error errors={["can't be blank"]} />
      <.field_error id="user_email-error" errors={["must be at least 3 characters", "is invalid"]} />
      <.field_error errors={[]} />
  """
  attr :id, :string,
    default: "field-error",
    doc: "id prefix for each error paragraph; suffixed with the error index"

  attr :errors, :list, default: []

  def field_error(assigns) do
    ~H"""
    <p
      :for={{msg, idx} <- Enum.with_index(@errors)}
      id={"#{@id}-#{idx}"}
      role="alert"
      aria-live="polite"
      class="mt-1.5 text-xs text-destructive"
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
    msg = translate_error_text(msg)

    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{translate_error_text(key)}}", translate_error_text(value))
    end)
  end

  defp translate_error_text(term) when is_binary(term), do: term
  defp translate_error_text(term) when is_atom(term), do: Atom.to_string(term)
  defp translate_error_text(term) when is_integer(term) or is_float(term), do: to_string(term)

  defp translate_error_text(term) when is_list(term) do
    if Enum.all?(term, &is_integer/1) do
      List.to_string(term)
    else
      inspect(term)
    end
  end

  defp translate_error_text(term), do: inspect(term)
end
