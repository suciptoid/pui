defmodule PUI.Select.Primitive do
  @moduledoc """
  Zero-style, hook-wired select parts.

  The root accepts `search_event` and `search_debounce` for server-backed
  search. Add `search/1` inside the listbox content when the select is
  searchable; the host LiveView owns querying and re-rendering the options.

  ## Parts

  | Part | Description |
  |------|-------------|
  | `root/1` | Hook root and remote-search configuration |
  | `input/1` | Hidden form value |
  | `trigger/1` | Accessible select trigger |
  | `value/1` | Selected label or placeholder |
  | `content/1` | Listbox content |
  | `search/1` | Zero-style search input |
  | `item/1` | Select option |
  """
  use Phoenix.Component

  attr :id, :string, required: true
  attr :value, :string, default: nil
  attr :search_event, :string, default: nil
  attr :search_debounce, :integer, default: 300
  attr :rest, :global
  slot :inner_block, required: true

  def root(assigns) do
    ~H|<div
  id={@id}
  data-value={@value}
  data-search-event={@search_event}
  data-search-debounce={@search_debounce}
  phx-hook="PUI.Select"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|
  end

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    ~H|<input
  id={@id}
  data-pui="select-value"
  type="hidden"
  name={@name}
  value={@value}
  aria-hidden="true"
  {@rest}
/>|
  end

  attr :id, :string, required: true
  attr :listbox_id, :string, required: true
  attr :invalid, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def trigger(assigns) do
    ~H|<button
  id={@id}
  type="button"
  aria-haspopup="listbox"
  aria-expanded="false"
  aria-controls={@listbox_id}
  aria-invalid={if @invalid, do: "true"}
  {@rest}
>{render_slot(@inner_block)}</button>|
  end

  attr :placeholder, :string, default: "Select an item"
  attr :rest, :global
  slot :inner_block

  def value(%{inner_block: []} = assigns) do
    ~H|<span data-pui="selected-label" data-slot="select-value" data-placeholder={@placeholder} {@rest}>{@placeholder}</span>|
  end

  def value(assigns) do
    ~H|<span data-pui="selected-label" data-slot="select-value" data-placeholder={@placeholder} {@rest}>{render_slot(
  @inner_block,
  @placeholder
)}</span>|
  end

  attr :id, :string, required: true
  attr :trigger_id, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def content(assigns) do
    ~H|<div
  id={@id}
  role="listbox"
  tabindex="-1"
  aria-labelledby={@trigger_id}
  aria-hidden="true"
  data-side="bottom"
  data-floating-strategy="absolute"
  data-reference-hidden="false"
  {@rest}
>
  {render_slot(@inner_block)}
</div>|
  end

  attr :id, :string, required: true
  attr :listbox_id, :string, default: nil
  attr :placeholder, :string, default: "Search item..."
  attr :rest, :global

  @doc """
  Renders the zero-style search input for a searchable select.

  Place this part inside `content/1`. The surrounding `root/1` controls whether
  typing dispatches a LiveView search event through `search_event`.
  """
  def search(assigns) do
    ~H"""
    <div id={@id} data-pui="combobox-search" phx-update="ignore" {@rest}>
      <input
        id={"#{@id}-input"}
        data-pui="select-search"
        type="text"
        role="searchbox"
        aria-controls={@listbox_id}
        placeholder={@placeholder}
        autocomplete="off"
        autocorrect="off"
        spellcheck="false"
      />
    </div>
    """
  end

  attr :value, :string, required: true
  attr :id, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def item(assigns) do
    ~H|<div id={@id} role="option" aria-selected="false" tabindex="-1" data-value={@value} {@rest}>
  {render_slot(@inner_block)}
</div>|
  end
end
