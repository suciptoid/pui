defmodule AppWeb.Live.DemoSelect do
  use AppWeb, :live_view
  use Maui

  alias AppWeb.DocComponents

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(count: 0, results: %{"hello" => "world"})
     |> assign(:form, to_form(%{"select" => "event"}))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("incr", _, socket) do
    {:noreply, socket |> assign(count: socket.assigns.count + 1)}
  end

  def handle_event("validate", params, socket) do
    select = Map.get(params, "select-comp", "")
    {:noreply, socket |> assign(form: to_form(%{params | "select" => select}), results: params)}
  end

  def handle_event("submit", params, socket) do
    dbg(params)
    {:noreply, socket}
  end

  def handle_event("add-new-item", _params, socket) do
    Maui.Flash.send_flash("Add new item clicked!")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <div class="space-y-8">
        <!-- Page Header -->
        <div>
          <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">Select</h1>
          <p class="mt-2 text-zinc-600 dark:text-zinc-400">
            A dropdown component for selecting items from a list. Supports searching, grouping, icons, and form integration.
          </p>
        </div>

        <!-- Basic Select -->
        <DocComponents.example_card
          title="Basic Select"
          description="Select with manually defined items and icons."
        >
          <div class="max-w-sm">
            <.select label="Select Food" id="select-basic" name="select-basic">
              <.select_item value="makan-value">
                <.icon name="hero-arrow-path" class="size-4" /> Makan
              </.select_item>
              <.select_item value="makan-value-2">
                <.icon name="hero-check" class="size-4" /> Makan Dua
              </.select_item>
            </.select>
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select label="Select Food" id="select-basic" name="select-basic">
  <.select_item value="makan-value">
    <.icon name="hero-arrow-path" class="size-4" /> Makan
  </.select_item>
  <.select_item value="makan-value-2">
    <.icon name="hero-check" class="size-4" /> Makan Dua
  </.select_item>
</.select>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Searchable Select -->
        <DocComponents.example_card
          title="Searchable Select"
          description="Enable searching by setting searchable={true}. Users can type to filter options."
        >
          <div class="max-w-sm">
            <.select
              label="Searchable Select"
              id="select-searchable"
              name="select-searchable"
              placeholder="Search options..."
              searchable={true}
              options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
            />
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  label="Searchable Select"
  id="select-searchable"
  name="select-searchable"
  placeholder="Search options..."
  searchable={true}
  options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
/>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Select with Default Value -->
        <DocComponents.example_card
          title="Select with Default Value"
          description="Pre-select an option using the value attribute."
        >
          <div class="max-w-sm">
            <.select
              label="Select with Default"
              id="select-default"
              name="select-default"
              placeholder="Select an option"
              searchable={true}
              value="Option 3"
              options={["Option 1", "Option 2", "Option 3"]}
            />
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  label="Select with Default"
  id="select-default"
  name="select-default"
  placeholder="Select an option"
  searchable={true}
  value="Option 3"
  options={["Option 1", "Option 2", "Option 3"]}
/>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Select from Strings -->
        <DocComponents.example_card
          title="Select from Strings"
          description="Pass a list of strings to the options attribute for simple value/label pairs."
        >
          <div class="max-w-sm">
            <.select
              label="Select from Strings"
              id="select-strings"
              name="select-strings"
              placeholder="Select an option"
              options={["Option A", "Option B", "Option C"]}
            />
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  label="Select from Strings"
  id="select-strings"
  name="select-strings"
  placeholder="Select an option"
  options={["Option A", "Option B", "Option C"]}
/>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Select from Tuples -->
        <DocComponents.example_card
          title="Select from Tuples"
          description="Use tuples {value, label} to separate the form value from the displayed label."
        >
          <div class="max-w-sm">
            <.select
              label="Select from Tuples"
              id="select-tuples"
              name="select-tuples"
              placeholder="Select an option"
              options={[{"val1", "Value One"}, {"val2", "Value Two"}]}
            />
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  label="Select from Tuples"
  id="select-tuples"
  name="select-tuples"
  placeholder="Select an option"
  options={[
    {"val1", "Value One"},
    {"val2", "Value Two"}
  ]}
/>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Grouped Select -->
        <DocComponents.example_card
          title="Grouped Select"
          description="Organize options into categories using nested tuples. Each group is a tuple {group_name, items}."
        >
          <div class="max-w-sm">
            <.select
              id="select-grouped"
              label="Select Grouped"
              name="select-grouped"
              placeholder="Select grouped"
              value="carrot"
              searchable={true}
              options={[
                {"Fruits", ["Apple", "Banana"]},
                {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}]}
              ]}
            />
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  id="select-grouped"
  label="Select Grouped"
  name="select-grouped"
  placeholder="Select grouped"
  value="carrot"
  searchable={true}
  options={[
    {"Fruits", ["Apple", "Banana"]},
    {"Vegetables", [
      {"carrot", "Carrot"},
      {"lettuce", "Lettuce"}
    ]}
  ]}
/>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Select with Footer -->
        <DocComponents.example_card
          title="Select with Footer"
          description="Add a footer slot for actions like adding new items."
        >
          <div class="max-w-sm">
            <.select
              label="Select with Footer"
              id="select-footer"
              name="select-footer"
              searchable={true}
            >
              <.select_item value="item-1">Item One</.select_item>
              <.select_item value="item-2">Item Two</.select_item>
              <.select_item value="item-3">Item Three</.select_item>
              <:footer>
                <div class="border-t border-border p-2">
                  <button
                    type="button"
                    phx-click="add-new-item"
                    class="flex items-center gap-2 text-sm text-primary"
                  >
                    <.icon name="hero-plus" class="size-4" /> Add New Item
                  </button>
                </div>
              </:footer>
            </.select>
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.select
  label="Select with Footer"
  id="select-footer"
  name="select-footer"
  searchable={true}
>
  <.select_item value="item-1">Item One</.select_item>
  <.select_item value="item-2">Item Two</.select_item>
  <.select_item value="item-3">Item Three</.select_item>
  <:footer>
    <div class="border-t border-border p-2">
      <button
        type="button"
        phx-click="add-new-item"
        class="flex items-center gap-2 text-sm text-primary"
      >
        <.icon name="hero-plus" class="size-4" /> Add New Item
      </button>
    </div>
  </:footer>
</.select>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Form Integration -->
        <DocComponents.example_card
          title="Form Integration"
          description="Select works seamlessly with Phoenix forms and handles validation state."
        >
          <div class="max-w-md">
            <.form
              :let={f}
              for={@form}
              phx-change="validate"
              phx-submit="submit"
              class="space-y-4"
            >
              <.select
                label="Select in Form"
                id="select-form"
                name="select-comp"
                placeholder="Choose an option"
                searchable={true}
                options={["Event", "Meeting", "Reminder"]}
              />
              <.input type="text" field={f[:select]} label="Current Value" />
              <.button type="submit">Submit</.button>
            </.form>
          </div>
          <div class="mt-4">
            <DocComponents.code_block
              language="heex"
              code={~S|<.form
  :let={f}
  for={@form}
  phx-change="validate"
  phx-submit="submit"
>
  <.select
    label="Select in Form"
    id="select-form"
    name="select-comp"
    placeholder="Choose an option"
    searchable={true}
    options={["Event", "Meeting", "Reminder"]}
  />
  <.input type="text" field={f[:select]} />
  <.button type="submit">Submit</.button>
</.form>|}
            />
          </div>
        </DocComponents.example_card>

        <!-- Props Table -->
        <div>
          <h2 class="text-xl font-semibold text-zinc-900 dark:text-zinc-100 mb-4">Props</h2>
          <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 overflow-hidden">
            <DocComponents.props_table
              props={[
                %{name: "id", type: "string", required: true, description: "Unique identifier for the select"},
                %{name: "name", type: "string", required: true, description: "Form field name"},
                %{name: "label", type: "string", default: "nil", description: "Label text displayed above the select"},
                %{name: "placeholder", type: "string", default: "\"Select...\"", description: "Placeholder text when no option is selected"},
                %{name: "searchable", type: "boolean", default: "false", description: "Enable search/filter functionality"},
                %{name: "options", type: "list", default: "[]", description: "List of options (strings, tuples, or grouped)"},
                %{name: "value", type: "string", default: "nil", description: "Currently selected value"},
                %{name: "class", type: "string", default: "nil", description: "Additional CSS classes"},
                %{name: "disabled", type: "boolean", default: "false", description: "Disable the select input"},
                %{name: "required", type: "boolean", default: "false", description: "Mark the field as required"},
                %{name: "errors", type: "list", default: "[]", description: "List of validation errors"}
              ]}
            />
          </div>
        </div>

        <!-- Form Results -->
        <div class="rounded-lg border border-zinc-200 dark:border-zinc-700 p-4 bg-zinc-50 dark:bg-zinc-800/50">
          <h3 class="text-sm font-semibold text-zinc-700 dark:text-zinc-300 mb-2">Form Results</h3>
          <code class="block whitespace-pre-wrap font-mono text-sm text-zinc-600 dark:text-zinc-400">
            {inspect(@results, pretty: true)}
          </code>
        </div>
      </div>
    </Layouts.docs>
    """
  end
end
