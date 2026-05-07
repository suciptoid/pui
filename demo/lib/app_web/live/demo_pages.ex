defmodule AppWeb.Live.DemoPages do
  @moduledoc "Function components for the PUI component showcase demo pages."
  use AppWeb, :html
  use PUI

  # ── Shared helpers ──────────────────────────────────────────────────────

  attr :page, :map, required: true
  slot :action

  def page_intro(assigns) do
    ~H"""
    <section class="overflow-hidden rounded-lg border border-border bg-background shadow-sm">
      <div class="border-b border-border bg-gradient-to-br from-primary/10 via-background to-background p-6 sm:p-8">
        <div class="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div class="max-w-3xl">
            <p class="text-sm font-semibold uppercase tracking-[0.22em] text-primary">
              {@page.eyebrow}
            </p>
            <h1 class="mt-3 text-3xl font-semibold tracking-tight text-foreground sm:text-4xl">
              {@page.title}
            </h1>
            <p class="mt-3 max-w-2xl text-base leading-7 text-muted-foreground">
              {@page.description}
            </p>
          </div>
          <%= if @action != [] do %>
            <div class="flex flex-wrap gap-2">
              {render_slot(@action)}
            </div>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :string, default: ""
  slot :action
  slot :inner_block, required: true

  def surface(assigns) do
    ~H"""
    <section class={[
      "overflow-hidden rounded-lg border border-border bg-background shadow-sm",
      @class
    ]}>
      <div class="flex flex-col gap-4 border-b border-border px-6 py-5 sm:flex-row sm:items-start sm:justify-between">
        <div class="space-y-1">
          <h2 class="text-base font-semibold text-foreground">{@title}</h2>
          <p :if={@description} class="max-w-3xl text-sm leading-6 text-muted-foreground">
            {@description}
          </p>
        </div>
        <%= if @action != [] do %>
          <div class="flex flex-wrap gap-2">
            {render_slot(@action)}
          </div>
        <% end %>
      </div>
      <div class="p-6">
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  # ── Button ──────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def button_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Variants" description="All button style variants.">
      <div class="flex flex-wrap items-center gap-3">
        <.button variant="default">Default</.button>
        <.button variant="secondary">Secondary</.button>
        <.button variant="destructive">Destructive</.button>
        <.button variant="outline">Outline</.button>
        <.button variant="ghost">Ghost</.button>
        <.button variant="link">Link</.button>
      </div>
    </.surface>

    <.surface title="Sizes" description="Four size options.">
      <div class="flex flex-wrap items-center gap-3">
        <.button size="sm">Small</.button>
        <.button size="default">Default</.button>
        <.button size="lg">Large</.button>
        <.button size="icon">
          <.icon name="hero-bell" class="size-4" />
        </.button>
      </div>
    </.surface>

    <.surface title="With Icons" description="Pair with hero icons for clearer actions.">
      <div class="flex flex-wrap items-center gap-3">
        <.button>
          <.icon name="hero-plus" class="size-4" /> Add Item
        </.button>
        <.button variant="destructive">
          <.icon name="hero-trash" class="size-4" /> Delete
        </.button>
        <.button variant="outline">
          <.icon name="hero-arrow-down-tray" class="size-4" /> Download
        </.button>
        <.button variant="secondary">
          <.icon name="hero-pencil" class="size-4" /> Edit
        </.button>
      </div>
    </.surface>

    <.surface title="Disabled" description="Non-interactive state for all variants.">
      <div class="flex flex-wrap items-center gap-3">
        <.button disabled>Default</.button>
        <.button variant="secondary" disabled>Secondary</.button>
        <.button variant="destructive" disabled>Destructive</.button>
        <.button variant="outline" disabled>Outline</.button>
        <.button variant="ghost" disabled>Ghost</.button>
      </div>
    </.surface>
    """
  end

  # ── Input ───────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def input_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Text Inputs" description="All standard input types.">
      <div class="max-w-sm space-y-4">
        <.input id="demo-text" name="demo-text" label="Full Name" placeholder="John Doe" />
        <.input
          id="demo-email"
          name="demo-email"
          type="email"
          label="Email"
          placeholder="you@example.com"
        />
        <.input
          id="demo-password"
          name="demo-password"
          type="password"
          label="Password"
          placeholder="········"
        />
        <.input id="demo-number" name="demo-number" type="number" label="Quantity" placeholder="12" />
      </div>
    </.surface>

    <.surface title="Textarea" description="Multi-line text input.">
      <div class="max-w-xl space-y-4">
        <.textarea
          id="demo-bio"
          name="bio"
          label="Biography"
          placeholder="Tell us about yourself..."
          rows="4"
        />
        <.textarea
          id="demo-feedback"
          name="feedback"
          label="Feedback"
          placeholder="Share your thoughts..."
          rows="6"
        />
      </div>
    </.surface>

    <.surface title="Checkbox, Radio & Switch" description="Binary and choice inputs.">
      <div class="grid gap-8 md:grid-cols-3">
        <div class="space-y-3">
          <p class="text-sm font-medium text-foreground">Checkbox</p>
          <.checkbox id="demo-terms" name="terms" label="Accept terms" />
          <.checkbox id="demo-newsletter" name="newsletter" label="Subscribe" checked />
          <.checkbox id="demo-disabled-cb" name="disabled-cb" label="Disabled" disabled />
        </div>
        <div class="space-y-3">
          <p class="text-sm font-medium text-foreground">Radio</p>
          <label class="flex items-center gap-3 text-sm">
            <.radio id="r1" name="plan" value="free" checked /> Free
          </label>
          <label class="flex items-center gap-3 text-sm">
            <.radio id="r2" name="plan" value="pro" /> Pro
          </label>
          <label class="flex items-center gap-3 text-sm">
            <.radio id="r3" name="plan" value="enterprise" /> Enterprise
          </label>
        </div>
        <div class="space-y-3">
          <p class="text-sm font-medium text-foreground">Switch</p>
          <.switch id="demo-notif" name="notif" label="Notifications" />
          <.switch id="demo-marketing" name="marketing" label="Product updates" />
          <.switch id="demo-disabled-sw" name="disabled-sw" label="Disabled" disabled />
        </div>
      </div>
    </.surface>

    <.surface title="Error States" description="Inputs with validation errors.">
      <div class="max-w-sm space-y-4">
        <.input
          id="demo-err-name"
          name="err-name"
          label="Name"
          placeholder="Required"
          errors={["Please enter your name."]}
        />
        <.input
          id="demo-err-email"
          name="err-email"
          type="email"
          label="Email"
          placeholder="Invalid"
          errors={["Please enter a valid email."]}
        />
        <.checkbox
          id="demo-err-terms"
          name="err-terms"
          label="Accept terms"
          errors={["Please accept the terms."]}
        />
      </div>
    </.surface>
    """
  end

  # ── Select ──────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def select_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Select" description="Simple option list.">
      <div class="max-w-sm">
        <.select
          id="demo-basic"
          name="basic"
          label="Favorite Fruit"
          options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
        />
      </div>
    </.surface>

    <.surface title="Searchable" description="Filter options by typing.">
      <div class="max-w-sm">
        <.select
          id="demo-search"
          name="search"
          label="Countries"
          placeholder="Type to search..."
          searchable={true}
          options={[
            "Argentina",
            "Brazil",
            "Canada",
            "Denmark",
            "Egypt",
            "France",
            "Germany",
            "India",
            "Japan"
          ]}
        />
      </div>
    </.surface>

    <.surface title="Grouped Options" description="Options organized by category.">
      <div class="max-w-sm">
        <.select
          id="demo-grouped"
          name="grouped"
          label="Food"
          searchable={true}
          options={[
            {"Fruits", ["Apple", "Banana", "Cherry"]},
            {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}, {"tomato", "Tomato"}]}
          ]}
        />
      </div>
    </.surface>

    <.surface title="Custom Items with Icons" description="Slot-based items with custom markup.">
      <div class="max-w-sm">
        <.select id="demo-custom" name="custom" label="Action">
          <.select_item value="edit">
            <.icon name="hero-pencil" class="size-4" /> Edit
          </.select_item>
          <.select_item value="duplicate">
            <.icon name="hero-document-duplicate" class="size-4" /> Duplicate
          </.select_item>
          <.select_item value="archive">
            <.icon name="hero-archive-box" class="size-4" /> Archive
          </.select_item>
        </.select>
      </div>
    </.surface>

    <.surface title="Footer Slot" description="Add actions below the options list.">
      <div class="max-w-sm">
        <.select id="demo-footer" name="footer" label="Items" searchable={true}>
          <.select_item value="item-1">Item One</.select_item>
          <.select_item value="item-2">Item Two</.select_item>
          <.select_item value="item-3">Item Three</.select_item>
          <:footer>
            <div class="border-t border-border p-2">
              <button
                type="button"
                class="flex items-center gap-2 text-sm text-primary hover:text-primary/80"
              >
                <.icon name="hero-plus" class="size-4" /> Add New Item
              </button>
            </div>
          </:footer>
        </.select>
      </div>
    </.surface>
    """
  end

  # ── Date Picker ─────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def date_picker_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Date Picker" description="Single date selection.">
      <div class="max-w-sm">
        <.date_picker
          id="demo-dp-basic"
          name="dp_basic"
          label="Publish date"
          default_month={~D[2026-04-01]}
        />
      </div>
    </.surface>

    <.surface title="Range Picker" description="Select a start and end date.">
      <div class="max-w-lg">
        <.range_picker
          id="demo-dp-range"
          from_name="trip_start"
          to_name="trip_end"
          label="Trip dates"
          default_month={~D[2026-04-01]}
        />
      </div>
    </.surface>

    <.surface title="Bounded Dates" description="Restrict selectable dates with min and max.">
      <div class="max-w-sm">
        <.date_picker
          id="demo-dp-bounds"
          name="dp_bounds"
          label="Delivery date"
          default_month={~D[2026-04-01]}
          min={~D[2026-04-10]}
          max={~D[2026-04-22]}
        />
      </div>
    </.surface>

    <.surface
      title="Footer Slot & Compact Header"
      description="Extend with footer content or hide the month selector."
    >
      <div class="grid gap-8 md:grid-cols-2">
        <div>
          <p class="mb-3 text-sm font-medium text-foreground">With footer</p>
          <.date_picker
            id="demo-dp-footer"
            name="dp_footer"
            label="Reminder"
            default_month={~D[2026-04-01]}
          >
            <:footer>
              <div class="flex items-center gap-2">
                <input
                  type="time"
                  value="09:30"
                  class="border-input dark:bg-input/30 h-9 rounded-md border bg-transparent px-3 text-sm shadow-xs outline-none"
                />
                <.button type="button" variant="outline" size="sm">Save time</.button>
              </div>
            </:footer>
          </.date_picker>
        </div>
        <div>
          <p class="mb-3 text-sm font-medium text-foreground">Compact header</p>
          <.date_picker
            id="demo-dp-compact"
            name="dp_compact"
            label="Compact"
            default_month={~D[2026-04-01]}
            selectable_month={false}
          />
        </div>
      </div>
    </.surface>
    """
  end

  # ── Dialog ──────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def dialog_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Dialog" description="Trigger-based modal with footer actions.">
      <.dialog id="demo-dialog-basic" size="md" title="Dialog Title">
        <:trigger :let={attr}>
          <.button {attr}>Open Dialog</.button>
        </:trigger>
        <div class="space-y-4">
          <p class="text-sm text-muted-foreground">
            This is a demonstration of the PUI dialog component. Dialogs are useful for confirmations, forms, and complex interactions that require user attention.
          </p>
        </div>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button phx-click={hide}>Confirm</.button>
          </div>
        </:footer>
      </.dialog>
    </.surface>

    <.surface title="Sizes" description="Four dialog sizes: sm, md, lg, xl.">
      <div class="flex flex-wrap gap-3">
        <.dialog id="demo-dialog-sm" size="sm" title="Small">
          <:trigger :let={attr}><.button variant="outline" {attr}>Small</.button></:trigger>
          <p class="text-sm text-muted-foreground">A compact dialog for quick confirmations.</p>
          <:footer :let={%{hide: hide}}><.button size="sm" phx-click={hide}>Close</.button></:footer>
        </.dialog>
        <.dialog id="demo-dialog-md" size="md" title="Medium">
          <:trigger :let={attr}><.button variant="outline" {attr}>Medium</.button></:trigger>
          <p class="text-sm text-muted-foreground">The default dialog size.</p>
          <:footer :let={%{hide: hide}}><.button phx-click={hide}>Close</.button></:footer>
        </.dialog>
        <.dialog id="demo-dialog-lg" size="lg" title="Large">
          <:trigger :let={attr}><.button variant="outline" {attr}>Large</.button></:trigger>
          <p class="text-sm text-muted-foreground">A large dialog with more room for content.</p>
          <:footer :let={%{hide: hide}}><.button phx-click={hide}>Close</.button></:footer>
        </.dialog>
        <.dialog id="demo-dialog-xl" size="xl" title="Extra Large">
          <:trigger :let={attr}><.button variant="outline" {attr}>Extra Large</.button></:trigger>
          <p class="text-sm text-muted-foreground">An extra large dialog for complex content.</p>
          <:footer :let={%{hide: hide}}><.button phx-click={hide}>Close</.button></:footer>
        </.dialog>
      </div>
    </.surface>

    <.surface title="Alert Dialog" description="Destructive confirmation with alert semantics.">
      <.dialog id="demo-dialog-alert" alert={true} size="sm" title="Are you sure?">
        <:trigger :let={attr}>
          <.button variant="destructive" {attr}>Delete Item</.button>
        </:trigger>
        <p class="text-sm text-muted-foreground">
          This action cannot be undone. This will permanently delete the item.
        </p>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button variant="destructive" phx-click={hide}>Delete</.button>
          </div>
        </:footer>
      </.dialog>
    </.surface>

    <.surface
      title="Scrollable Body"
      description="Content scrolls while title and footer stay visible."
    >
      <.dialog id="demo-dialog-scroll" size="lg" title="Recent activity">
        <:trigger :let={attr}>
          <.button variant="outline" {attr}>Scrollable dialog</.button>
        </:trigger>
        <div class="space-y-4">
          <p :for={i <- 1..20} class="text-sm text-muted-foreground">
            Activity #{i}: This dialog body scrolls automatically when the content grows taller than the viewport.
          </p>
        </div>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Close</.button>
            <.button phx-click={hide}>Save changes</.button>
          </div>
        </:footer>
      </.dialog>
    </.surface>

    <.surface title="No Close Button" description="Disable the built-in close button.">
      <.dialog id="demo-dialog-noclose" size="md" title="Review order" show_close={false}>
        <:trigger :let={attr}>
          <.button variant="outline" {attr}>No close button</.button>
        </:trigger>
        <p class="text-sm text-muted-foreground">
          Disable the built-in close button when you want a custom action row only.
        </p>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Back</.button>
            <.button phx-click={hide}>Continue</.button>
          </div>
        </:footer>
      </.dialog>
    </.surface>

    <.surface
      title="Form Inside Dialog"
      description="Collect structured input through a modal overlay."
    >
      <.dialog id="demo-dialog-form" title="Create new project" size="lg">
        <:trigger :let={attr}>
          <.button {attr}>
            <.icon name="hero-plus" class="size-4" /> New project
          </.button>
        </:trigger>
        <form class="space-y-4">
          <.input id="dialog-project-name" label="Project name" placeholder="My new project" />
          <.textarea
            id="dialog-project-desc"
            label="Description"
            rows="4"
            placeholder="What is this project about?"
          />
          <.select
            id="dialog-project-cat"
            label="Category"
            options={["Engineering", "Design", "Marketing", "Operations"]}
          />
        </form>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button>Create project</.button>
          </div>
        </:footer>
      </.dialog>
    </.surface>
    """
  end

  # ── Dropdown ────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def dropdown_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Menu" description="Simple dropdown with items.">
      <.menu_button>
        Actions
        <:item>Edit</:item>
        <:item>Duplicate</:item>
        <:item>Archive</:item>
      </.menu_button>
    </.surface>

    <.surface title="With Shortcuts" description="Display keyboard shortcuts alongside items.">
      <.menu_button>
        File
        <:item shortcut="⌘N">New File</:item>
        <:item shortcut="⌘O">Open</:item>
        <:item shortcut="⌘S">Save</:item>
        <:item shortcut="⇧⌘S">Save As</:item>
      </.menu_button>
    </.surface>

    <.surface title="Destructive Actions" description="Highlight dangerous items.">
      <.menu_button>
        Manage
        <:item>Settings</:item>
        <:item>Export Data</:item>
        <:item variant="destructive">Delete Account</:item>
      </.menu_button>
    </.surface>

    <.surface title="Button Variants" description="Trigger buttons come in multiple styles.">
      <div class="flex flex-wrap gap-3">
        <.menu_button variant="default">
          Default
          <:item>Item 1</:item>
          <:item>Item 2</:item>
        </.menu_button>
        <.menu_button variant="outline">
          Outline
          <:item>Item 1</:item>
          <:item>Item 2</:item>
        </.menu_button>
        <.menu_button variant="ghost">
          Ghost
          <:item>Item 1</:item>
          <:item>Item 2</:item>
        </.menu_button>
      </div>
    </.surface>
    """
  end

  # ── Alert ───────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def alert_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Default & Destructive" description="Two alert variants for different contexts.">
      <div class="space-y-4">
        <.alert>
          <:icon><.icon name="hero-information-circle" class="size-5" /></:icon>
          <:title>Heads up!</:title>
          <:description>You can add components to your app using the CLI.</:description>
        </.alert>
        <.alert variant="destructive">
          <:icon><.icon name="hero-exclamation-triangle" class="size-5" /></:icon>
          <:title>Error</:title>
          <:description>Something went wrong. Please try again later.</:description>
        </.alert>
      </div>
    </.surface>

    <.surface
      title="With Custom Content"
      description="Use alerts for inline feedback and status messages."
    >
      <div class="space-y-4">
        <.alert>
          <div class="flex items-center gap-3">
            <.icon name="hero-check-circle" class="size-5 text-green-500" />
            <div>
              <p class="font-semibold text-sm">Success!</p>
              <p class="text-sm text-muted-foreground">Your changes have been saved successfully.</p>
            </div>
          </div>
        </.alert>
        <.alert>
          <div class="flex items-center gap-3">
            <.icon name="hero-sparkles" class="size-5 text-primary" />
            <div>
              <p class="font-semibold text-sm">New feature available</p>
              <p class="text-sm text-muted-foreground">
                Check out the latest chart components with colocated hooks.
              </p>
            </div>
          </div>
        </.alert>
      </div>
    </.surface>
    """
  end

  # ── Flash ───────────────────────────────────────────────────────────────

  attr :page, :map, required: true
  attr :toast_count, :integer, default: 0

  def flash_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface
      title="Send Toast"
      description="Trigger live toast notifications. The flash group renders in the top-right corner."
    >
      <div class="flex flex-wrap items-center gap-4">
        <.button phx-click="send_toast">
          <.icon name="hero-bell" class="size-4" /> Send Toast
        </.button>
        <p class="text-sm text-muted-foreground">
          Toasts sent: <span class="font-medium text-foreground">{@toast_count}</span>
        </p>
      </div>
    </.surface>

    <.surface
      title="Configuration"
      description="Flash groups support multiple positions and live/static modes."
    >
      <div class="grid gap-4 md:grid-cols-2">
        <div class="rounded-lg border border-border p-4">
          <p class="text-sm font-medium text-foreground">Positions</p>
          <p class="mt-1 text-sm text-muted-foreground">
            top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
          </p>
        </div>
        <div class="rounded-lg border border-border p-4">
          <p class="text-sm font-medium text-foreground">Usage</p>
          <p class="mt-1 text-sm text-muted-foreground">
            <code class="text-xs">
              {"<PUI.Flash.flash_group flash={@flash} live={true} position=\"top-right\" />"}
            </code>
          </p>
        </div>
      </div>
    </.surface>
    """
  end

  # ── Tabs ────────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def tabs_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Client-Controlled Tabs" description="Tabs that switch instantly in the browser.">
      <.tabs id="demo-tabs-client" default_value="overview" class="max-w-3xl">
        <:trigger value="overview">Overview</:trigger>
        <:trigger value="analytics">Analytics</:trigger>
        <:trigger value="reports">Reports</:trigger>
        <:trigger value="settings" disabled>Settings</:trigger>
        <:content value="overview">
          <div class="space-y-2">
            <h3 class="text-base font-semibold text-foreground">Overview</h3>
            <p class="text-sm text-muted-foreground">
              Client-controlled tabs switch instantly while preserving ARIA attributes and roving focus behavior.
            </p>
          </div>
        </:content>
        <:content value="analytics">
          <div class="space-y-2">
            <h3 class="text-base font-semibold text-foreground">Analytics</h3>
            <p class="text-sm text-muted-foreground">
              Arrow keys move focus between tabs, and Space or Enter activates the focused tab.
            </p>
          </div>
        </:content>
        <:content value="reports">
          <div class="space-y-2">
            <h3 class="text-base font-semibold text-foreground">Reports</h3>
            <p class="text-sm text-muted-foreground">
              Use disabled triggers when a section exists conceptually but is not currently available.
            </p>
          </div>
        </:content>
        <:content value="settings">
          <p class="text-sm text-muted-foreground">This panel is disabled in the trigger list.</p>
        </:content>
      </.tabs>
    </.surface>

    <.surface title="Line Variant" description="Tabs with an underline indicator style.">
      <.tabs id="demo-tabs-line" default_value="preview" variant="line" class="max-w-3xl">
        <:trigger value="preview">Preview</:trigger>
        <:trigger value="code">Code</:trigger>
        <:trigger value="diff">Diff</:trigger>
        <:content value="preview">
          <p class="text-sm text-muted-foreground">Preview content appears here.</p>
        </:content>
        <:content value="code">
          <p class="text-sm text-muted-foreground">Code content appears here.</p>
        </:content>
        <:content value="diff">
          <p class="text-sm text-muted-foreground">Diff content appears here.</p>
        </:content>
      </.tabs>
    </.surface>

    <.surface title="Vertical Tabs" description="Tabs arranged vertically for settings-like layouts.">
      <.tabs id="demo-tabs-vertical" default_value="account" orientation="vertical" class="max-w-3xl">
        <:trigger value="account">Account</:trigger>
        <:trigger value="notifications">Notifications</:trigger>
        <:trigger value="security">Security</:trigger>
        <:content value="account">
          <div class="space-y-2">
            <h3 class="font-semibold text-foreground">Account</h3>
            <p class="text-sm text-muted-foreground">
              Vertical tabs are useful for settings sidebars and longer navigation labels.
            </p>
          </div>
        </:content>
        <:content value="notifications">
          <div class="space-y-2">
            <h3 class="font-semibold text-foreground">Notifications</h3>
            <p class="text-sm text-muted-foreground">
              In vertical mode, ArrowUp and ArrowDown move through the tab list.
            </p>
          </div>
        </:content>
        <:content value="security">
          <div class="space-y-2">
            <h3 class="font-semibold text-foreground">Security</h3>
            <p class="text-sm text-muted-foreground">
              Configure session policies, 2FA requirements, and export controls.
            </p>
          </div>
        </:content>
      </.tabs>
    </.surface>
    """
  end

  # ── Accordion ───────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def accordion_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Single Open" description="Only one item can be open at a time (shared name).">
      <.accordion class="max-w-2xl">
        <.accordion_item name="demo-faq" open>
          <.accordion_trigger>How does single-open behavior work?</.accordion_trigger>
          <.accordion_content>
            Give sibling items the same name attribute to let the browser keep only one item open at a time.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item name="demo-faq">
          <.accordion_trigger>Do I need JavaScript?</.accordion_trigger>
          <.accordion_content>
            No. The component uses native details/summary elements.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item name="demo-faq">
          <.accordion_trigger>Can I place rich markup inside?</.accordion_trigger>
          <.accordion_content>
            Yes. Content panels can contain forms, lists, cards, or any HEEx markup.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.surface>

    <.surface
      title="Multiple Open"
      description="All items can be open simultaneously (no shared name)."
    >
      <.accordion class="max-w-2xl rounded-xl border border-border px-4">
        <.accordion_item open class="last:border-b-0">
          <.accordion_trigger>Notifications</.accordion_trigger>
          <.accordion_content>
            Configure email digests, product announcements, and incident alerts.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item class="last:border-b-0">
          <.accordion_trigger>Privacy</.accordion_trigger>
          <.accordion_content>
            Review audit logs, active sessions, and workspace access policies.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item class="last:border-b-0">
          <.accordion_trigger>Billing</.accordion_trigger>
          <.accordion_content>
            Update payment methods, manage invoices, and compare plan limits.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.surface>

    <.surface title="Headless / Unstyled" description="Use variant=unstyled to bring your own design.">
      <.accordion variant="unstyled" class="max-w-2xl space-y-3">
        <.accordion_item
          variant="unstyled"
          class="rounded-2xl border border-primary/20 bg-primary/5 shadow-sm"
          open
        >
          <.accordion_trigger
            variant="unstyled"
            class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left text-sm font-semibold text-foreground"
          >
            Custom styled item
            <span class="rounded-full bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
              Open
            </span>
          </.accordion_trigger>
          <.accordion_content
            variant="unstyled"
            class="px-5 pb-5 text-sm leading-6 text-muted-foreground"
          >
            PUI keeps the semantic structure while you control spacing, borders, colors, and decorative UI details yourself.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.surface>
    """
  end

  # ── Container ───────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def container_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Card" description="A simple card with header, content, and footer.">
      <PUI.Container.card class="max-w-md">
        <PUI.Container.card_header>
          <PUI.Container.card_title>Profile</PUI.Container.card_title>
          <PUI.Container.card_description>
            Manage your account details.
          </PUI.Container.card_description>
        </PUI.Container.card_header>
        <PUI.Container.card_content>
          <p class="text-sm text-muted-foreground">
            The card component is a versatile container for grouping related content.
          </p>
        </PUI.Container.card_content>
        <PUI.Container.card_footer class="flex justify-end gap-2">
          <.button variant="outline" size="sm">Cancel</.button>
          <.button size="sm">Save</.button>
        </PUI.Container.card_footer>
      </PUI.Container.card>
    </.surface>

    <.surface title="Card with Action" description="Header action slot for buttons or menus.">
      <PUI.Container.card class="max-w-md">
        <PUI.Container.card_header>
          <PUI.Container.card_title>Team Members</PUI.Container.card_title>
          <PUI.Container.card_description>Manage your team.</PUI.Container.card_description>
          <PUI.Container.card_action>
            <.button size="sm" variant="outline">
              <.icon name="hero-plus" class="size-4 mr-1" /> Add
            </.button>
          </PUI.Container.card_action>
        </PUI.Container.card_header>
        <PUI.Container.card_content>
          <div class="space-y-2">
            <div :for={name <- ["Alice", "Bob"]} class="flex items-center gap-3 py-2">
              <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                {String.at(name, 0)}
              </div>
              <div>
                <p class="text-sm font-medium">{name}</p>
                <p class="text-xs text-muted-foreground">{String.downcase(name)}@example.com</p>
              </div>
            </div>
          </div>
        </PUI.Container.card_content>
      </PUI.Container.card>
    </.surface>
    """
  end

  # ── Chart ───────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def charts_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface
      title="Bar Chart"
      description="Categorical comparisons with the preconfigured bar_chart helper."
    >
      <.bar_chart
        id="demo-bar-chart"
        categories={["Jan", "Feb", "Mar", "Apr", "May", "Jun"]}
        height={280}
        series={[
          %{label: "Revenue", data: [12.4, 18.7, 15.2, 22.1, 19.8, 25.3], suffix: " jt"},
          %{label: "Target", data: [10.0, 14.0, 16.0, 18.0, 20.0, 24.0], suffix: " jt"}
        ]}
      />
    </.surface>

    <.surface
      title="Line Chart Curves"
      description="Three curve renderers: linear, stepped, and spline."
    >
      <div class="grid gap-6 lg:grid-cols-3">
        <div>
          <p class="mb-3 text-sm font-medium text-foreground">Linear</p>
          <.line_chart
            id="demo-line-linear"
            height={200}
            labels={["Mon", "Tue", "Wed", "Thu", "Fri"]}
            series={[%{label: "CPU", data: [42, 45, 43, 46, 44], suffix: "%"}]}
          />
        </div>
        <div>
          <p class="mb-3 text-sm font-medium text-foreground">Stepped</p>
          <.line_chart
            id="demo-line-stepped"
            curve="stepped"
            height={200}
            labels={["Mon", "Tue", "Wed", "Thu", "Fri"]}
            series={[%{label: "CPU", data: [42, 45, 43, 46, 44], suffix: "%"}]}
          />
        </div>
        <div>
          <p class="mb-3 text-sm font-medium text-foreground">Spline</p>
          <.line_chart
            id="demo-line-spline"
            curve="spline"
            height={200}
            labels={["Mon", "Tue", "Wed", "Thu", "Fri"]}
            series={[%{label: "CPU", data: [42, 45, 43, 46, 44], suffix: "%"}]}
          />
        </div>
      </div>
    </.surface>

    <.surface title="Area Chart" description="Line chart with area fill beneath each series.">
      <.line_chart
        id="demo-area-chart"
        area={true}
        height={260}
        labels={["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"]}
        series={[
          %{label: "Revenue", data: [42, 48, 45, 52, 58, 64], suffix: "k"},
          %{label: "Target", data: [40, 40, 50, 50, 60, 60], suffix: "k"}
        ]}
      />
    </.surface>

    <.surface
      title="Sparkline"
      description="Compact charts without axes or chrome for embedding in cards."
    >
      <div class="grid gap-4 md:grid-cols-3">
        <div
          :for={
            {data, idx} <-
              Enum.with_index([
                [85, 92, 88, 101, 109, 115, 128],
                [38, 40, 39, 41, 40, 42, 42],
                [9, 7, 8, 6, 7, 5, 3]
              ])
          }
          class="rounded-lg border border-border bg-card p-4"
        >
          <.line_chart
            id={"demo-sparkline-#{idx}"}
            sparkline={true}
            height={40}
            series={[%{data: data}]}
          />
        </div>
      </div>
    </.surface>

    <.surface
      title="Colocated Hook"
      description="Register a custom hook in app.js that extends LineChart to hide axes and grid for a minimal look."
    >
      <div class="mb-3 flex items-center gap-2">
        <.badge variant="outline">.MiniChart</.badge>
        <span class="text-xs text-muted-foreground">Extends LineChart, hides axes</span>
      </div>
      <.line_chart
        id="demo-colocated-mini"
        phx-hook=".MiniChart"
        height={180}
        labels={["Mon", "Tue", "Wed", "Thu", "Fri"]}
        series={[%{label: "CPU", data: [42, 45, 43, 46, 44], suffix: "%"}]}
      />
      <script :type={Phoenix.LiveView.ColocatedHook} name=".MiniChart">
        import { LineChart } from "pui";

        export default class MiniChart extends LineChart {
          buildAxes(_payload) {
            return [{ show: false }, { show: false }];
          }
        }
      </script>
    </.surface>
    """
  end

  # ── Popover & Tooltip ───────────────────────────────────────────────────

  attr :page, :map, required: true

  def popover_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface title="Basic Popover" description="Click-triggered popup with custom content.">
      <.popover_base
        id="demo-popover-basic"
        class="w-fit"
        phx-hook="PUI.Popover"
        data-placement="bottom"
      >
        <:trigger class="inline-flex h-9 items-center justify-center gap-2 whitespace-nowrap rounded-md border border-input bg-transparent px-4 py-2 text-sm font-medium shadow-xs transition hover:bg-accent hover:text-accent-foreground">
          Show Popover
        </:trigger>
        <:popup class="aria-hidden:hidden block min-w-[250px] rounded-md border border-border bg-popover p-4 text-popover-foreground shadow-md z-50">
          <div class="space-y-2 w-64">
            <h3 class="font-semibold text-sm">Popover Title</h3>
            <p class="text-sm text-muted-foreground">
              This is a popover with some helpful content. Click the trigger again to close.
            </p>
          </div>
        </:popup>
      </.popover_base>
    </.surface>

    <.surface title="Tooltip Placements" description="Tooltips in all four directions.">
      <div class="flex flex-wrap items-center gap-6">
        <.tooltip id="demo-tt-top" placement="top">
          <.button variant="outline" size="sm">Top</.button>
          <:tooltip>Tooltip on top</:tooltip>
        </.tooltip>
        <.tooltip id="demo-tt-bottom" placement="bottom">
          <.button variant="outline" size="sm">Bottom</.button>
          <:tooltip>Tooltip on bottom</:tooltip>
        </.tooltip>
        <.tooltip id="demo-tt-left" placement="left">
          <.button variant="outline" size="sm">Left</.button>
          <:tooltip>Tooltip on left</:tooltip>
        </.tooltip>
        <.tooltip id="demo-tt-right" placement="right">
          <.button variant="outline" size="sm">Right</.button>
          <:tooltip>Tooltip on right</:tooltip>
        </.tooltip>
      </div>
    </.surface>

    <.surface title="Rich Tooltip" description="Tooltips can hold richer contextual guidance.">
      <.tooltip id="demo-tt-rich" placement="bottom">
        <.button variant="outline">Hover for details</.button>
        <:tooltip>
          <div class="w-56 space-y-2">
            <p class="text-sm font-medium">Tooltip content</p>
            <p class="text-xs text-muted-foreground">
              Tooltips can hold short, contextual guidance without taking over the layout.
            </p>
          </div>
        </:tooltip>
      </.tooltip>
    </.surface>
    """
  end

  # ── Loading ─────────────────────────────────────────────────────────────

  attr :page, :map, required: true

  def loading_page(assigns) do
    ~H"""
    <.page_intro page={@page} />

    <.surface
      title="Loading Topbar"
      description="A thin progress bar at the top of the page during navigation."
    >
      <div class="space-y-4">
        <p class="text-sm text-muted-foreground">
          The loading topbar is already active on this page. Navigate between demo pages using the sidebar to see it in action at the very top of the viewport.
        </p>
        <div class="rounded-lg border border-border bg-muted/20 p-4">
          <p class="text-sm font-medium text-foreground">How it works</p>
          <p class="mt-1 text-sm text-muted-foreground">
            PUI.Loading installs a hook on the root layout that listens for phx:page-loading-start and phx:page-loading-stop events. It renders a thin animated bar that appears during navigation and disappears when the new page mounts.
          </p>
        </div>
      </div>
    </.surface>
    """
  end
end
