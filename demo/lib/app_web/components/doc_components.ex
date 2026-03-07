defmodule AppWeb.DocComponents do
  @moduledoc """
  Reusable documentation components for showcasing UI examples.

  Includes components for:
  - `example_card` - Basic example container with title
  - `code_block` - Syntax-highlighted code with copy button
  - `props_table` - Component props documentation table
  - `live_code_preview` - Side-by-side demo and code display
  - `component_api_section` - Consistent API documentation layout
  - `playground_controls` - Interactive variant/size selectors
  """
  use Phoenix.Component

  @doc """
  Renders an example card with title, optional description, and content.

  ## Examples

      <.example_card title="Button Variants">
        <.button>Primary</.button>
      </.example_card>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil

  slot :inner_block, required: true

  def example_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
      <h3 class="text-lg font-semibold text-zinc-900 dark:text-zinc-100">{@title}</h3>
      <p :if={@description} class="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        {@description}
      </p>
      <div class="mt-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Renders a code block with syntax highlighting styling and a copy button.

  ## Examples

      <.code_block code={~s|<.button>Click me</.button>|} language="elixir" />
  """
  attr :code, :string, required: true
  attr :language, :string, default: "elixir"

  def code_block(assigns) do
    ~H"""
    <div class="relative group">
      <button
        type="button"
        class="absolute top-2 right-2 p-2 rounded-md bg-zinc-700 hover:bg-zinc-600 text-zinc-300 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
        phx-hook="CopyCode"
        id={"copy-#{System.unique_integer([:positive])}"}
        data-code={@code}
        aria-label="Copy code"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-4"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75"
          />
        </svg>
      </button>
      <pre class="rounded-lg bg-zinc-900 p-4 overflow-x-auto"><code
          class={"language-#{@language} font-mono text-sm text-zinc-100"}
          phx-no-curly-interpolation
        >{@code}</code></pre>
    </div>
    """
  end

  @doc """
  Renders a table showing component props.

  ## Examples

      <.props_table props={[
        %{name: "variant", type: "atom", default: ":primary", description: "The button style variant"},
        %{name: "size", type: "atom", default: ":md", description: "The button size"}
      ]} />
  """
  attr :props, :list, required: true

  def props_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-zinc-200 dark:border-zinc-700">
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">Name</th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">Type</th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">
              Default
            </th>
            <th class="text-left py-2 px-3 font-semibold text-zinc-900 dark:text-zinc-100">
              Description
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            :for={prop <- @props}
            class="border-b border-zinc-100 dark:border-zinc-800 last:border-0"
          >
            <td class="py-2 px-3 font-mono text-zinc-800 dark:text-zinc-200">{prop.name}</td>
            <td class="py-2 px-3 font-mono text-zinc-600 dark:text-zinc-400">{prop.type}</td>
            <td class="py-2 px-3 font-mono text-zinc-600 dark:text-zinc-400">
              {prop[:default] || "-"}
            </td>
            <td class="py-2 px-3 text-zinc-600 dark:text-zinc-400">{prop[:description] || "-"}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a side-by-side live preview with code block.

  Shows an interactive demo on the left and the corresponding code on the right.
  Perfect for component playgrounds where users can see both the result and how to achieve it.

  ## Examples

      <.live_code_preview id="button-demo">
        <:preview>
          <.button variant={@variant} size={@size}>Click Me</.button>
        </:preview>
        <:code>
          <.button variant={@variant} size={@size}>Click Me</.button>
        </:code>
      </.live_code_preview>
  """
  attr :id, :string, required: true
  attr :class, :string, default: ""

  slot :preview, required: true do
    attr :class, :string
  end

  slot :code, required: true do
    attr :class, :string
  end

  def live_code_preview(assigns) do
    ~H"""
    <div id={@id} class={["grid grid-cols-1 lg:grid-cols-2 gap-4", @class]}>
      <div class={["rounded-lg border border-zinc-200 dark:border-zinc-700 p-6 bg-zinc-50 dark:bg-zinc-800/50", @preview[:class]]}>
        <div class="flex items-center justify-center min-h-[100px]">
          {render_slot(@preview)}
        </div>
      </div>
      <.code_block code={rendered_code(@code)} language="heex" />
    </div>
    """
  end

  defp rendered_code(code_slot) do
    case code_slot do
      [code_item] when is_map(code_item) ->
        case code_item.inner_block do
          [block | _] when is_function(block, 1) ->
            # Get the template source from assigns
            assigns = code_item[:assigns] || %{}
            block.(assigns)
            |> Phoenix.HTML.Safe.to_iodata()
            |> IO.iodata_to_binary()
            |> String.trim()
          _ ->
            ""
        end
      _ ->
        ""
    end
  end

  @doc """
  Renders a consistent API documentation section for a component.

  Includes import statement, props table, and usage examples in a standardized format.

  ## Examples

      <.component_api_section
        module="Maui.Button"
        function="button"
        import_statement="use Maui"
        props={[
          %{name: "variant", type: "atom", default: ":default", description: "Button style variant"},
          %{name: "size", type: "atom", default: ":default", description: "Button size"}
        ]}
      >
        <:example title="Basic Button">
          <.button>Click Me</.button>
        </:example>
        <:example title="With Variant">
          <.button variant="destructive">Delete</.button>
        </:example>
      </.component_api_section>
  """
  attr :module, :string, required: true
  attr :function, :string, default: nil
  attr :import_statement, :string, required: true
  attr :props, :list, default: []
  attr :class, :string, default: ""

  slot :example do
    attr :title, :string
  end

  slot :description

  def component_api_section(assigns) do
    ~H"""
    <div class={["space-y-8", @class]}>
      <!-- Import Statement -->
      <div>
        <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-3 flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5" />
          </svg>
          Import
        </h3>
        <.code_block code={@import_statement} language="elixir" />
      </div>

      <!-- Description -->
      <div :if={@description}>
        <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-3">Description</h3>
        <p class="text-zinc-600 dark:text-zinc-400 text-sm leading-relaxed">
          {render_slot(@description)}
        </p>
      </div>

      <!-- Props Table -->
      <div :if={@props != []}>
        <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-3 flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 0 1 6 3.75h2.25A2.25 2.25 0 0 1 10.5 6v2.25a2.25 2.25 0 0 1-2.25 2.25H6a2.25 2.25 0 0 1-2.25-2.25V6ZM3.75 15.75A2.25 2.25 0 0 1 6 13.5h2.25a2.25 2.25 0 0 1 2.25 2.25V18a2.25 2.25 0 0 1-2.25 2.25H6A2.25 2.25 0 0 1 3.75 18v-2.25ZM13.5 6a2.25 2.25 0 0 1 2.25-2.25H18A2.25 2.25 0 0 1 20.25 6v2.25A2.25 2.25 0 0 1 18 10.5h-2.25a2.25 2.25 0 0 1-2.25-2.25V6ZM13.5 15.75a2.25 2.25 0 0 1 2.25-2.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-2.25A2.25 2.25 0 0 1 13.5 18v-2.25Z" />
          </svg>
          Props
        </h3>
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
          <.props_table props={@props} />
        </div>
      </div>

      <!-- Examples -->
      <div :if={@example != []}>
        <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 mb-3 flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 0 1 4.5 9.75h15A2.25 2.25 0 0 1 21.75 12v.75m-8.69-6.44-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z" />
          </svg>
          Examples
        </h3>
        <div class="space-y-4">
          <div :for={example <- @example} class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <div class="bg-zinc-50 dark:bg-zinc-800/50 px-4 py-2 border-b border-zinc-200 dark:border-zinc-700">
              <h4 class="text-sm font-medium text-zinc-700 dark:text-zinc-300">
                {example[:title] || "Example"}
              </h4>
            </div>
            <div class="p-4 bg-white dark:bg-zinc-900">
              {render_slot(example)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders playground controls for interactive component demos.

  Provides toggle buttons for variants, sizes, and other options.
  Used alongside live_code_preview to create interactive playgrounds.

  ## Examples

      <.playground_controls
        id="button-playground"
        variants={["default", "secondary", "destructive", "outline", "ghost", "link"]}
        sizes={["sm", "default", "lg"]}
        selected_variant={@variant}
        selected_size={@size}
      />
  """
  attr :id, :string, required: true
  attr :variants, :list, default: []
  attr :sizes, :list, default: []
  attr :states, :list, default: []
  attr :selected_variant, :string, default: nil
  attr :selected_size, :string, default: nil
  attr :selected_state, :string, default: nil
  attr :class, :string, default: ""

  def playground_controls(assigns) do
    ~H"""
    <div id={@id} class={["flex flex-wrap items-center gap-4 p-4 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-zinc-50 dark:bg-zinc-800/50", @class]}>
      <!-- Variant Selector -->
      <div :if={@variants != []} class="flex items-center gap-2">
        <label class="text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase tracking-wide">
          Variant
        </label>
        <div class="flex flex-wrap gap-1">
          <button
            :for={variant <- @variants}
            type="button"
            phx-click="select_variant"
            phx-value-variant={variant}
            class={[
              "px-3 py-1 text-xs font-medium rounded-md transition-colors",
              if(variant == @selected_variant,
                do: "bg-primary text-primary-foreground",
                else: "bg-white dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-600 border border-zinc-200 dark:border-zinc-600"
              )
            ]}
          >
            {variant}
          </button>
        </div>
      </div>

      <!-- Size Selector -->
      <div :if={@sizes != []} class="flex items-center gap-2">
        <label class="text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase tracking-wide">
          Size
        </label>
        <div class="flex flex-wrap gap-1">
          <button
            :for={size <- @sizes}
            type="button"
            phx-click="select_size"
            phx-value-size={size}
            class={[
              "px-3 py-1 text-xs font-medium rounded-md transition-colors",
              if(size == @selected_size,
                do: "bg-primary text-primary-foreground",
                else: "bg-white dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-600 border border-zinc-200 dark:border-zinc-600"
              )
            ]}
          >
            {size}
          </button>
        </div>
      </div>

      <!-- State Selector -->
      <div :if={@states != []} class="flex items-center gap-2">
        <label class="text-xs font-semibold text-zinc-500 dark:text-zinc-400 uppercase tracking-wide">
          State
        </label>
        <div class="flex flex-wrap gap-1">
          <button
            :for={state <- @states}
            type="button"
            phx-click="select_state"
            phx-value-state={state}
            class={[
              "px-3 py-1 text-xs font-medium rounded-md transition-colors",
              if(state == @selected_state,
                do: "bg-primary text-primary-foreground",
                else: "bg-white dark:bg-zinc-700 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-600 border border-zinc-200 dark:border-zinc-600"
              )
            ]}
          >
            {state}
          </button>
        </div>
      </div>
    </div>
    """
  end
end
