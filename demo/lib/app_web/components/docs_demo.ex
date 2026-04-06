defmodule AppWeb.DocsDemo do
  @moduledoc """
  Reusable inline documentation demos rendered from markdown via MDEx.

  Each public function is a Phoenix component intended to be referenced from
  docs markdown with a fully qualified module/function tag such as
  `<AppWeb.DocsDemo.select_demo form={@form} />`.
  """
  use AppWeb, :html
  use PUI

  def button_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <%!-- Playground --%>
      <div class="rounded-xl border border-border bg-background shadow-sm">
        <div class="rounded-t-xl bg-muted/30 px-5 py-3 border-b border-border">
          <h3 class="text-sm font-medium text-foreground">Playground</h3>
        </div>
        <div class="rounded-b-xl p-6 flex flex-col gap-6 overflow-visible">
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Variant
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={
                  v <-
                    ~w(default secondary destructive outline ghost link)
                }
                type="button"
                phx-click="select_variant"
                phx-value-variant={v}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  v == @btn_variant &&
                    "bg-primary text-primary-foreground shadow-sm",
                  v != @btn_variant &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {v}
              </button>
            </div>
          </div>
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Size
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={s <- ~w(sm default lg icon)}
                type="button"
                phx-click="select_size"
                phx-value-size={s}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  s == @btn_size &&
                    "bg-primary text-primary-foreground shadow-sm",
                  s != @btn_size &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {s}
              </button>
            </div>
          </div>
          <div class="flex items-center justify-center py-8 rounded-lg bg-muted/20 border border-dashed border-border">
            <.button variant={@btn_variant} size={@btn_size}>
              {if @btn_size == "icon", do: "🔔", else: "Button"}
            </.button>
          </div>
        </div>
      </div>

      <%!-- Variants showcase --%>
      <.demo_section title="All Variants" id="all-variants">
        <div class="flex flex-wrap items-center gap-3">
          <.button variant="default">Default</.button>
          <.button variant="secondary">Secondary</.button>
          <.button variant="destructive">Destructive</.button>
          <.button variant="outline">Outline</.button>
          <.button variant="ghost">Ghost</.button>
          <.button variant="link">Link</.button>
        </div>
      </.demo_section>

      <%!-- Sizes showcase --%>
      <.demo_section title="Sizes" id="sizes">
        <div class="flex flex-wrap items-center gap-3">
          <.button size="sm">Small</.button>
          <.button size="default">Default</.button>
          <.button size="lg">Large</.button>
          <.button size="icon">
            <.icon name="hero-bell" class="size-4" />
          </.button>
        </div>
      </.demo_section>

      <%!-- With icons --%>
      <.demo_section title="With Icons" id="with-icons">
        <div class="flex flex-wrap items-center gap-3">
          <.button>
            <.icon name="hero-plus" class="size-4 mr-2" /> Add Item
          </.button>
          <.button variant="destructive">
            <.icon name="hero-trash" class="size-4 mr-2" /> Delete
          </.button>
          <.button variant="outline">
            <.icon name="hero-arrow-down-tray" class="size-4 mr-2" /> Download
          </.button>
        </div>
      </.demo_section>

      <%!-- Disabled --%>
      <.demo_section title="Disabled" id="disabled">
        <div class="flex flex-wrap items-center gap-3">
          <.button disabled>Disabled</.button>
          <.button variant="secondary" disabled>Disabled</.button>
          <.button variant="outline" disabled>Disabled</.button>
        </div>
      </.demo_section>
    </section>
    """
  end

  def button_playground_demo(assigns) do
    ~H"""
    <section class="space-y-4">
      <h3 class="text-lg font-semibold text-foreground">Interactive Playground</h3>

      <div class="rounded-xl border border-border bg-background shadow-sm">
        <div class="rounded-t-xl bg-muted/30 px-5 py-3 border-b border-border">
          <h4 class="text-sm font-medium text-foreground">Playground</h4>
        </div>
        <div class="rounded-b-xl p-6 flex flex-col gap-6 overflow-visible">
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Variant
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={v <- ~w(default secondary destructive outline ghost link)}
                type="button"
                phx-click="select_variant"
                phx-value-variant={v}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  v == @btn_variant && "bg-primary text-primary-foreground shadow-sm",
                  v != @btn_variant &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {v}
              </button>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Size
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={s <- ~w(sm default lg icon)}
                type="button"
                phx-click="select_size"
                phx-value-size={s}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  s == @btn_size && "bg-primary text-primary-foreground shadow-sm",
                  s != @btn_size &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {s}
              </button>
            </div>
          </div>

          <div class="flex items-center justify-center py-8 rounded-lg bg-muted/20 border border-dashed border-border">
            <.button variant={@btn_variant} size={@btn_size}>
              {if @btn_size == "icon", do: "🔔", else: "Button"}
            </.button>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def button_variants_demo(assigns) do
    ~H"""
    <.demo_section title="Rendered Variants" id="button-variants-demo">
      <div class="flex flex-wrap items-center gap-3">
        <.button variant="default">Default</.button>
        <.button variant="secondary">Secondary</.button>
        <.button variant="destructive">Destructive</.button>
        <.button variant="outline">Outline</.button>
        <.button variant="ghost">Ghost</.button>
        <.button variant="link">Link</.button>
      </div>
    </.demo_section>
    """
  end

  def button_sizes_demo(assigns) do
    ~H"""
    <.demo_section title="Rendered Sizes" id="button-sizes-demo">
      <div class="flex flex-wrap items-center gap-3">
        <.button size="sm">Small</.button>
        <.button size="default">Default</.button>
        <.button size="lg">Large</.button>
        <.button size="icon">
          <.icon name="hero-bell" class="size-4" />
        </.button>
      </div>
    </.demo_section>
    """
  end

  def button_disabled_demo(assigns) do
    ~H"""
    <.demo_section title="Disabled Buttons" id="button-disabled-demo">
      <div class="flex flex-wrap items-center gap-3">
        <.button disabled>Disabled</.button>
        <.button variant="secondary" disabled>Disabled</.button>
        <.button variant="outline" disabled>Disabled</.button>
      </div>
    </.demo_section>
    """
  end

  def button_icons_demo(assigns) do
    ~H"""
    <.demo_section title="Buttons with Icons" id="button-icons-demo">
      <div class="flex flex-wrap items-center gap-3">
        <.button>
          <.icon name="hero-plus" class="size-4 mr-2" /> Add Item
        </.button>
        <.button variant="destructive">
          <.icon name="hero-trash" class="size-4 mr-2" /> Delete
        </.button>
        <.button variant="outline">
          <.icon name="hero-arrow-down-tray" class="size-4 mr-2" /> Download
        </.button>
      </div>
    </.demo_section>
    """
  end

  def accordion_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Single Open FAQ" id="accordion-single-open">
        <.accordion class="max-w-2xl">
          <.accordion_item name="docs-faq" open>
            <.accordion_trigger>How does single-open behavior work?</.accordion_trigger>
            <.accordion_content>
              Give sibling items the same <code>name</code> attribute to let the
              browser keep only one item open at a time.
            </.accordion_content>
          </.accordion_item>

          <.accordion_item name="docs-faq">
            <.accordion_trigger>Do I need JavaScript for this component?</.accordion_trigger>
            <.accordion_content>
              No. The component is built on native <code>&lt;details&gt;</code>
              and <code>&lt;summary&gt;</code>
              elements, so the toggle behavior works
              without a custom hook.
            </.accordion_content>
          </.accordion_item>

          <.accordion_item name="docs-faq">
            <.accordion_trigger>Can I place rich markup inside the content?</.accordion_trigger>
            <.accordion_content>
              <div class="space-y-3">
                <p>
                  Yes. Content panels can contain forms, lists, cards, or any
                  other HEEx markup.
                </p>
                <ul class="list-disc space-y-1 pl-5">
                  <li>Simple FAQ answers</li>
                  <li>Settings sections</li>
                  <li>Compact dashboards and inspectors</li>
                </ul>
              </div>
            </.accordion_content>
          </.accordion_item>
        </.accordion>
      </.demo_section>

      <.demo_section title="Multiple Open Items" id="accordion-multiple-open">
        <.accordion class="max-w-2xl rounded-xl border border-border px-4">
          <.accordion_item open class="last:border-b-0">
            <.accordion_trigger>Notifications</.accordion_trigger>
            <.accordion_content>
              Configure email digests, product announcements, and incident
              alerts for your team.
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
      </.demo_section>

      <.demo_section title="Unstyled / Headless" id="accordion-headless-demo">
        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <.accordion variant="unstyled" class="space-y-3">
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
                PUI keeps the semantic structure while you control spacing,
                borders, colors, and decorative UI details yourself.
              </.accordion_content>
            </.accordion_item>
          </.accordion>

          <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
            <p class="font-medium text-foreground">What PUI still handles</p>
            <ul class="mt-3 space-y-2">
              <li>Accessible native disclosure semantics</li>
              <li>Composable trigger and content primitives</li>
              <li>Styled and unstyled usage patterns</li>
            </ul>
          </div>
        </div>
      </.demo_section>
    </section>
    """
  end

  def accordion_single_demo(assigns) do
    ~H"""
    <.demo_section title="Single Open Accordion" id="accordion-single-demo">
      <.accordion class="max-w-2xl">
        <.accordion_item name="accordion-single" open>
          <.accordion_trigger>How do I reset my password?</.accordion_trigger>
          <.accordion_content>
            Use the password reset flow from the sign-in page and follow the
            emailed link to create a new password.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item name="accordion-single">
          <.accordion_trigger>Can I change my plan later?</.accordion_trigger>
          <.accordion_content>
            Yes. You can upgrade or downgrade your plan from billing settings at
            any time.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item name="accordion-single">
          <.accordion_trigger>What payment methods are supported?</.accordion_trigger>
          <.accordion_content>
            We support major credit cards, invoice billing for larger teams, and
            regional payment methods where available.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.demo_section>
    """
  end

  def accordion_multiple_demo(assigns) do
    ~H"""
    <.demo_section title="Multiple Open Accordion" id="accordion-multiple-demo">
      <.accordion class="max-w-2xl rounded-xl border border-border px-4">
        <.accordion_item open class="last:border-b-0">
          <.accordion_trigger>Notification Settings</.accordion_trigger>
          <.accordion_content>
            Manage which updates arrive by email, in-app inbox, or mobile push.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item class="last:border-b-0">
          <.accordion_trigger>Privacy & Security</.accordion_trigger>
          <.accordion_content>
            Configure session policies, 2FA requirements, and export controls.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item class="last:border-b-0">
          <.accordion_trigger>Billing & Subscription</.accordion_trigger>
          <.accordion_content>
            Review invoices, compare plans, and manage workspace billing owners.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.demo_section>
    """
  end

  def accordion_headless_demo(assigns) do
    ~H"""
    <.demo_section title="Headless Accordion Demo" id="accordion-headless-demo-card">
      <.accordion variant="unstyled" class="max-w-2xl space-y-3">
        <.accordion_item
          variant="unstyled"
          class="overflow-hidden rounded-2xl border border-border bg-background shadow-sm"
          open
        >
          <.accordion_trigger
            variant="unstyled"
            class="flex w-full items-center justify-between gap-4 px-5 py-4 text-left text-sm font-semibold text-foreground"
          >
            Bring your own layout <.icon name="hero-sparkles" class="size-4 text-primary" />
          </.accordion_trigger>
          <.accordion_content
            variant="unstyled"
            class="border-t border-border px-5 py-4 text-sm leading-6 text-muted-foreground"
          >
            This example drops the default shadcn-like treatment but keeps the
            composable building blocks for your own design system.
          </.accordion_content>
        </.accordion_item>
      </.accordion>
    </.demo_section>
    """
  end

  def headless_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Unstyled Button and Menu" id="unstyled-button-and-menu">
        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <div class="flex flex-wrap items-start gap-4">
            <.button
              variant="unstyled"
              class="inline-flex items-center rounded-xl bg-zinc-950 px-4 py-2 text-sm font-medium text-white shadow-sm transition-colors hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200"
            >
              Custom Trigger
            </.button>

            <.menu_button
              variant="unstyled"
              class="inline-flex items-center gap-2 rounded-xl border border-primary/30 bg-primary/10 px-4 py-2 text-sm font-medium text-primary transition-colors hover:bg-primary/15"
              content_class="aria-hidden:hidden block min-w-48 rounded-xl border border-border bg-background p-1 shadow-xl"
            >
              Custom Menu
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
                <.icon name="hero-user" class="size-4" /> Profile
              </:item>
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
                <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
              </:item>
              <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-destructive transition-colors hover:bg-destructive/10">
                <.icon name="hero-trash" class="size-4" /> Delete
              </:item>
            </.menu_button>
          </div>

          <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
            <p class="font-medium text-foreground">What PUI still handles</p>
            <ul class="mt-3 space-y-2">
              <li>ARIA attributes and keyboard navigation</li>
              <li>Popover positioning, dismissal, and focus behavior</li>
              <li>Slot-based composition for items and triggers</li>
            </ul>
          </div>
        </div>
      </.demo_section>

      <.demo_section title="Low-level Popover Hook" id="low-level-popover-hook">
        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
          <.popover_base
            id="docs-headless-popover"
            class="w-fit"
            phx-hook="PUI.Popover"
            data-placement="bottom-start"
          >
            <:trigger class="inline-flex items-center gap-2 rounded-xl border border-border bg-background px-4 py-2 text-sm font-medium text-foreground shadow-sm transition-colors hover:bg-accent">
              <.icon name="hero-code-bracket" class="size-4" /> Open custom popover
            </:trigger>
            <:popup class="aria-hidden:hidden block w-72 rounded-2xl border border-border bg-background p-4 shadow-xl">
              <div class="space-y-3">
                <span class="inline-flex rounded-full bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
                  Level 1
                </span>
                <h3 class="text-sm font-semibold text-foreground">Low-level hook example</h3>
                <p class="text-sm text-muted-foreground">
                  This example uses <code>popover_base</code>
                  directly so you control the trigger markup,
                  popup container, and every utility class yourself.
                </p>
              </div>
            </:popup>
          </.popover_base>

          <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
            <p class="font-medium text-foreground">When to use this</p>
            <ul class="mt-3 space-y-2">
              <li>Building a custom design system on top of PUI behavior</li>
              <li>Reusing Floating UI positioning with your own markup</li>
              <li>Creating bespoke popovers, menus, or tooltips</li>
            </ul>
          </div>
        </div>
      </.demo_section>
    </section>
    """
  end

  def input_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Text Inputs" id="text-inputs">
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
            placeholder="••••••••"
          />
          <.input
            id="demo-number"
            name="demo-number"
            type="number"
            label="Quantity"
            placeholder="12"
            min="0"
          />
        </div>
      </.demo_section>

      <.demo_section title="Phoenix Form Errors" id="input-errors">
        <.form for={@form} phx-change="validate" class="max-w-sm space-y-4">
          <.input field={@form[:name]} label="Full Name" placeholder="Jane Doe" />
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="jane@example.com"
          />
        </.form>
      </.demo_section>
    </section>
    """
  end

  def textarea_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Textareas" id="basic-textareas">
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
            label="Team Feedback"
            placeholder="Share context, blockers, or ideas..."
            rows="6"
          />
        </div>
      </.demo_section>

      <.demo_section title="Validation Errors" id="textarea-errors">
        <.form for={@form} phx-change="validate" class="max-w-xl space-y-4">
          <.textarea
            field={@form[:notes]}
            label="Project Notes"
            placeholder="Add a short update for your team..."
            rows="5"
          />
        </.form>
      </.demo_section>
    </section>
    """
  end

  def checkbox_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Checkbox States" id="checkbox-states">
        <div class="space-y-4">
          <.checkbox id="demo-terms" name="terms" label="I agree to the terms and conditions" />
          <.checkbox id="demo-newsletter" name="newsletter" label="Subscribe to newsletter" checked />
          <.checkbox id="demo-disabled-checkbox" name="disabled" label="Disabled checkbox" disabled />
        </div>
      </.demo_section>

      <.demo_section title="Error State" id="checkbox-errors">
        <div class="space-y-4 max-w-sm">
          <.checkbox
            id="demo-terms-error"
            name="terms-error"
            label="I agree to the terms and conditions"
            errors={["Please accept the terms to continue."]}
          />
        </div>
      </.demo_section>
    </section>
    """
  end

  def checkbox_states_demo(assigns) do
    ~H"""
    <.demo_section title="Checkbox States Demo" id="checkbox-states-demo">
      <div class="space-y-4">
        <.checkbox id="demo-terms" name="terms" label="I agree to the terms and conditions" />
        <.checkbox id="demo-newsletter" name="newsletter" label="Subscribe to newsletter" checked />
        <.checkbox id="demo-disabled-checkbox" name="disabled" label="Disabled checkbox" disabled />
      </div>
    </.demo_section>
    """
  end

  def checkbox_errors_demo(assigns) do
    ~H"""
    <.demo_section title="Checkbox Errors Demo" id="checkbox-errors-demo">
      <div class="space-y-4 max-w-sm">
        <.checkbox
          id="demo-terms-error"
          name="terms-error"
          label="I agree to the terms and conditions"
          errors={["Please accept the terms to continue."]}
        />
      </div>
    </.demo_section>
    """
  end

  def radio_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Radio Group" id="radio-group">
        <div class="space-y-3">
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-starter" name="demo-plan" value="starter" checked />
            <span class="text-sm text-foreground">Starter</span>
          </label>
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-pro" name="demo-plan" value="pro" />
            <span class="text-sm text-foreground">Pro</span>
          </label>
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-enterprise" name="demo-plan" value="enterprise" />
            <span class="text-sm text-foreground">Enterprise</span>
          </label>
        </div>
      </.demo_section>

      <.demo_section title="Error State" id="radio-errors">
        <div class="space-y-3 max-w-sm">
          <div class="space-y-2">
            <label class="flex items-center gap-3">
              <.radio id="demo-plan-error" name="demo-plan-error" value="starter" />
              <span class="text-sm text-foreground">Starter</span>
            </label>
          </div>
          <div>
            <label class="flex items-center gap-3">
              <.radio id="demo-plan-error-pro" name="demo-plan-error" value="pro" />
              <span class="text-sm text-foreground">Pro</span>
            </label>
          </div>
          <p class="text-destructive text-sm mt-1">Choose a plan to continue.</p>
        </div>
      </.demo_section>
    </section>
    """
  end

  def radio_group_demo(assigns) do
    ~H"""
    <.demo_section title="Radio Group Demo" id="radio-group-demo">
      <div class="space-y-3">
        <label class="flex items-center gap-3">
          <.radio id="demo-plan-starter" name="demo-plan" value="starter" checked />
          <span class="text-sm text-foreground">Starter</span>
        </label>
        <label class="flex items-center gap-3">
          <.radio id="demo-plan-pro" name="demo-plan" value="pro" />
          <span class="text-sm text-foreground">Pro</span>
        </label>
        <label class="flex items-center gap-3">
          <.radio id="demo-plan-enterprise" name="demo-plan" value="enterprise" />
          <span class="text-sm text-foreground">Enterprise</span>
        </label>
      </div>
    </.demo_section>
    """
  end

  def radio_errors_demo(assigns) do
    ~H"""
    <.demo_section title="Radio Errors Demo" id="radio-errors-demo">
      <div class="space-y-3 max-w-sm">
        <div class="space-y-2">
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-error" name="demo-plan-error" value="starter" />
            <span class="text-sm text-foreground">Starter</span>
          </label>
        </div>
        <div>
          <label class="flex items-center gap-3">
            <.radio id="demo-plan-error-pro" name="demo-plan-error" value="pro" />
            <span class="text-sm text-foreground">Pro</span>
          </label>
        </div>
        <p class="text-destructive text-sm mt-1">Choose a plan to continue.</p>
      </div>
    </.demo_section>
    """
  end

  def switch_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Switches" id="switches">
        <div class="space-y-4">
          <.switch id="demo-notifications" name="notifications" label="Enable notifications" />
          <.switch id="demo-marketing" name="marketing" label="Receive product updates" />
          <.switch id="demo-disabled-switch" name="disabled-switch" label="Disabled switch" disabled />
        </div>
      </.demo_section>

      <.demo_section title="Error State" id="switch-errors">
        <div class="space-y-4 max-w-sm">
          <.switch
            id="demo-switch-error"
            name="demo-switch-error"
            label="Enable notifications"
            errors={["Turn this on before continuing."]}
          />
        </div>
      </.demo_section>
    </section>
    """
  end

  def switch_basic_demo(assigns) do
    ~H"""
    <.demo_section title="Switch Demo" id="switch-basic-demo">
      <div class="space-y-4">
        <.switch id="demo-notifications" name="notifications" label="Enable notifications" />
        <.switch id="demo-marketing" name="marketing" label="Receive product updates" />
      </div>
    </.demo_section>
    """
  end

  def switch_disabled_demo(assigns) do
    ~H"""
    <.demo_section title="Disabled Switch Demo" id="switch-disabled-demo">
      <div class="space-y-4">
        <.switch
          id="demo-disabled-switch"
          name="disabled-switch"
          label="Disabled switch"
          disabled
        />
      </div>
    </.demo_section>
    """
  end

  def switch_errors_demo(assigns) do
    ~H"""
    <.demo_section title="Switch Errors Demo" id="switch-errors-demo">
      <div class="space-y-4 max-w-sm">
        <.switch
          id="demo-switch-error"
          name="demo-switch-error"
          label="Enable notifications"
          errors={["Turn this on before continuing."]}
        />
      </div>
    </.demo_section>
    """
  end

  def select_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Select" id="basic-select">
        <div class="max-w-sm">
          <.select
            id="demo-basic"
            name="demo-basic"
            label="Favorite Fruit"
            options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
          />
        </div>
      </.demo_section>

      <.demo_section title="Searchable" id="searchable">
        <div class="max-w-sm">
          <.select
            id="demo-search"
            name="demo-search"
            label="Search Countries"
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
      </.demo_section>

      <.demo_section title="Grouped Options" id="grouped-options">
        <div class="max-w-sm">
          <.select
            id="demo-grouped"
            name="demo-grouped"
            label="Select Food"
            searchable={true}
            options={[
              {"Fruits", ["Apple", "Banana", "Cherry"]},
              {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}, {"tomato", "Tomato"}]}
            ]}
          />
        </div>
      </.demo_section>

      <.demo_section title="Custom Items with Icons" id="custom-items">
        <div class="max-w-sm">
          <.select id="demo-custom" name="demo-custom" label="Select Action">
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
      </.demo_section>

      <.demo_section title="With Footer" id="select-footer">
        <div class="max-w-sm">
          <.select id="demo-footer" name="demo-footer" label="Items" searchable={true}>
            <.select_item value="item-1">Item One</.select_item>
            <.select_item value="item-2">Item Two</.select_item>
            <.select_item value="item-3">Item Three</.select_item>
            <:footer>
              <div class="border-t border-border p-2">
                <button
                  type="button"
                  phx-click="add-new-item"
                  class="flex items-center gap-2 text-sm text-primary hover:text-primary/80"
                >
                  <.icon name="hero-plus" class="size-4" /> Add New Item
                </button>
              </div>
            </:footer>
          </.select>
        </div>
      </.demo_section>

      <.demo_section title="Phoenix Form Errors" id="select-errors">
        <.form for={@form} phx-change="validate" class="max-w-sm">
          <.select
            field={@form[:select]}
            label="Favorite Fruit"
            placeholder="Choose one"
            options={["Apple", "Banana", "Cherry", "Date"]}
          />
        </.form>
      </.demo_section>
    </section>
    """
  end

  def select_basic_demo(assigns) do
    ~H"""
    <.demo_section title="Basic Select Demo" id="select-basic-demo">
      <div class="max-w-sm">
        <.select
          id="demo-basic"
          name="demo-basic"
          label="Favorite Fruit"
          options={["Apple", "Banana", "Cherry", "Date", "Elderberry","Pisang", "Melon","Anggur", "Manggis", "Kelapa","Jambu", "Salak", "Semangka", "Alpukat", "Tamarin", "Nangka", "Durian"]}
        />
      </div>
    </.demo_section>
    """
  end

  def select_custom_items_demo(assigns) do
    ~H"""
    <.demo_section title="Custom Items Demo" id="select-custom-items-demo">
      <div class="max-w-sm">
        <.select id="demo-custom" name="demo-custom" label="Select Action">
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
    </.demo_section>
    """
  end

  def select_searchable_demo(assigns) do
    ~H"""
    <.demo_section title="Searchable Select Demo" id="select-searchable-demo">
      <div class="max-w-sm">
        <.select
          id="demo-search"
          name="demo-search"
          label="Search Countries"
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
    </.demo_section>
    """
  end

  def select_grouped_demo(assigns) do
    ~H"""
    <.demo_section title="Grouped Options Demo" id="select-grouped-demo">
      <div class="max-w-sm">
        <.select
          id="demo-grouped"
          name="demo-grouped"
          label="Select Food"
          searchable={true}
          options={[
            {"Fruits", ["Apple", "Banana", "Cherry"]},
            {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}, {"tomato", "Tomato"}]}
          ]}
        />
      </div>
    </.demo_section>
    """
  end

  def select_footer_demo(assigns) do
    ~H"""
    <.demo_section title="Footer Slot Demo" id="select-footer-demo">
      <div class="max-w-sm">
        <.select id="demo-footer" name="demo-footer" label="Items" searchable={true}>
          <.select_item value="item-1">Item One</.select_item>
          <.select_item value="item-2">Item Two</.select_item>
          <.select_item value="item-3">Item Three</.select_item>
          <:footer>
            <div class="border-t border-border p-2">
              <button
                type="button"
                phx-click="add-new-item"
                class="flex items-center gap-2 text-sm text-primary hover:text-primary/80"
              >
                <.icon name="hero-plus" class="size-4" /> Add New Item
              </button>
            </div>
          </:footer>
        </.select>
      </div>
    </.demo_section>
    """
  end

  def select_form_demo(assigns) do
    ~H"""
    <.demo_section title="Form Integration Demo" id="select-form-demo">
      <.form for={@form} phx-change="validate" class="max-w-sm">
        <.select
          field={@form[:select]}
          label="Favorite Fruit"
          placeholder="Choose one"
          options={["Apple", "Banana", "Cherry", "Date"]}
        />
      </.form>
    </.demo_section>
    """
  end

  def tabs_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Client-Controlled Tabs" id="tabs-client-demo">
        <.tabs id="docs-tabs-client" default_value="overview" class="max-w-3xl">
          <:trigger id="docs-tabs-client-overview" value="overview">Overview</:trigger>
          <:trigger id="docs-tabs-client-analytics" value="analytics">Analytics</:trigger>
          <:trigger id="docs-tabs-client-reports" value="reports">Reports</:trigger>
          <:trigger id="docs-tabs-client-settings" value="settings" disabled>Settings</:trigger>

          <:content id="docs-tabs-client-panel-overview" value="overview">
            <div class="space-y-3">
              <h3 class="text-base font-semibold text-foreground">Overview</h3>
              <p class="text-sm text-muted-foreground">
                Client-controlled tabs switch instantly in the browser while still
                preserving the correct ARIA attributes and roving focus behavior.
              </p>
            </div>
          </:content>

          <:content id="docs-tabs-client-panel-analytics" value="analytics">
            <div class="space-y-3">
              <h3 class="text-base font-semibold text-foreground">Analytics</h3>
              <p class="text-sm text-muted-foreground">
                Arrow keys move focus between tabs, and `Space` or `Enter`
                activates the focused tab in the default manual mode.
              </p>
            </div>
          </:content>

          <:content id="docs-tabs-client-panel-reports" value="reports">
            <div class="space-y-3">
              <h3 class="text-base font-semibold text-foreground">Reports</h3>
              <p class="text-sm text-muted-foreground">
                Use disabled triggers when a section exists conceptually but is not
                currently available.
              </p>
            </div>
          </:content>

          <:content id="docs-tabs-client-panel-settings" value="settings">
            <div class="space-y-3">
              <h3 class="text-base font-semibold text-foreground">Settings</h3>
              <p class="text-sm text-muted-foreground">
                This panel is intentionally disabled in the demo trigger list.
              </p>
            </div>
          </:content>
        </.tabs>
      </.demo_section>

      <.demo_section title="Server-Controlled Tabs" id="tabs-server-demo">
        <div class="space-y-4">
          <.tabs
            id="docs-tabs-demo-server"
            value={@active_tab}
            client_controlled={false}
            variant="line"
            class="max-w-3xl"
          >
            <:trigger
              id="docs-tabs-demo-server-overview"
              value="overview"
              phx-click="select_tab"
              phx-value-tab="overview"
            >
              Overview
            </:trigger>

            <:trigger
              id="docs-tabs-demo-server-billing"
              value="billing"
              phx-click="select_tab"
              phx-value-tab="billing"
            >
              Billing
            </:trigger>

            <:trigger
              id="docs-tabs-demo-server-members"
              value="members"
              phx-click="select_tab"
              phx-value-tab="members"
            >
              Members
            </:trigger>

            <:content id="docs-tabs-demo-server-panel-overview" value="overview">
              <div class="rounded-lg border border-border bg-card p-4">
                <h3 class="font-semibold text-card-foreground">Overview</h3>
                <p class="mt-2 text-sm text-muted-foreground">
                  This panel is driven by LiveView state, so the server decides
                  which tab is active.
                </p>
              </div>
            </:content>

            <:content id="docs-tabs-demo-server-panel-billing" value="billing">
              <div class="rounded-lg border border-border bg-card p-4">
                <h3 class="font-semibold text-card-foreground">Billing</h3>
                <p class="mt-2 text-sm text-muted-foreground">
                  Clicking a trigger sends an event to the server, which re-renders
                  the tabs with the selected value.
                </p>
              </div>
            </:content>

            <:content id="docs-tabs-demo-server-panel-members" value="members">
              <div class="rounded-lg border border-border bg-card p-4">
                <h3 class="font-semibold text-card-foreground">Members</h3>
                <p class="mt-2 text-sm text-muted-foreground">
                  This mode works in LiveView and in server-rendered dead views as
                  long as you update the `value` assign on the server.
                </p>
              </div>
            </:content>
          </.tabs>

          <p id="docs-tabs-demo-server-value" class="text-sm text-muted-foreground">
            Server active tab: {@active_tab}
          </p>
        </div>
      </.demo_section>

      <.demo_section title="Vertical Tabs" id="tabs-vertical-demo">
        <.tabs
          id="docs-tabs-vertical"
          default_value="account"
          orientation="vertical"
          class="max-w-3xl"
        >
          <:trigger id="docs-tabs-vertical-account" value="account">Account</:trigger>
          <:trigger id="docs-tabs-vertical-notifications" value="notifications">
            Notifications
          </:trigger>
          <:trigger id="docs-tabs-vertical-security" value="security">Security</:trigger>

          <:content id="docs-tabs-vertical-panel-account" value="account">
            <div class="space-y-2">
              <h3 class="font-semibold text-foreground">Account</h3>
              <p class="text-sm text-muted-foreground">
                Vertical tabs are useful for settings sidebars and longer navigation labels.
              </p>
            </div>
          </:content>

          <:content id="docs-tabs-vertical-panel-notifications" value="notifications">
            <div class="space-y-2">
              <h3 class="font-semibold text-foreground">Notifications</h3>
              <p class="text-sm text-muted-foreground">
                In vertical mode, `ArrowUp` and `ArrowDown` move through the tab list.
              </p>
            </div>
          </:content>

          <:content id="docs-tabs-vertical-panel-security" value="security">
            <div class="space-y-2">
              <h3 class="font-semibold text-foreground">Security</h3>
              <p class="text-sm text-muted-foreground">
                Use `activation_mode="manual"` if you want focus and selection to be separate.
              </p>
            </div>
          </:content>
        </.tabs>
      </.demo_section>
    </section>
    """
  end

  def tabs_client_demo(assigns) do
    ~H"""
    <.demo_section title="Client-Controlled Tabs Demo" id="tabs-client-demo-card">
      <.tabs id="docs-tabs-client-inline" default_value="preview" class="max-w-2xl">
        <:trigger id="docs-tabs-client-inline-preview" value="preview">Preview</:trigger>
        <:trigger id="docs-tabs-client-inline-code" value="code">Code</:trigger>
        <:content id="docs-tabs-client-inline-panel-preview" value="preview">
          <p class="text-sm text-muted-foreground">Preview content appears here.</p>
        </:content>
        <:content id="docs-tabs-client-inline-panel-code" value="code">
          <p class="text-sm text-muted-foreground">Code content appears here.</p>
        </:content>
      </.tabs>
    </.demo_section>
    """
  end

  def tabs_server_demo(assigns) do
    ~H"""
    <.demo_section title="Server-Controlled Tabs Demo" id="tabs-server-demo-card">
      <div class="space-y-4">
        <.tabs
          id="docs-tabs-server-inline"
          value={@active_tab}
          client_controlled={false}
          variant="line"
        >
          <:trigger
            id="docs-tabs-server-overview"
            value="overview"
            phx-click="select_tab"
            phx-value-tab="overview"
          >
            Overview
          </:trigger>
          <:trigger
            id="docs-tabs-server-billing"
            value="billing"
            phx-click="select_tab"
            phx-value-tab="billing"
          >
            Billing
          </:trigger>
          <:content value="overview">Overview content.</:content>
          <:content value="billing">Billing content.</:content>
        </.tabs>
        <p id="docs-tabs-server-value" class="text-sm text-muted-foreground">
          Server active tab: {@active_tab}
        </p>
      </div>
    </.demo_section>
    """
  end

  def tabs_vertical_demo(assigns) do
    ~H"""
    <.demo_section title="Vertical Tabs Demo" id="tabs-vertical-demo-card">
      <.tabs id="docs-tabs-vertical-inline" default_value="account" orientation="vertical">
        <:trigger value="account">Account</:trigger>
        <:trigger value="security">Security</:trigger>
        <:content value="account">Account content.</:content>
        <:content value="security">Security content.</:content>
      </.tabs>
    </.demo_section>
    """
  end

  def dialog_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Dialog" id="basic-dialog">
        <.dialog id="demo-dialog" size="md" title="Dialog Title">
          <:trigger :let={attr}>
            <.button {attr}>Open Dialog</.button>
          </:trigger>

          <div class="space-y-4">
            <p class="text-sm text-muted-foreground">
              This is a demonstration of the PUI dialog component.
            </p>
            <p class="text-sm text-muted-foreground">
              Dialogs are useful for confirmations, forms, and complex interactions that require user attention.
            </p>
          </div>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end gap-2">
              <.button variant="outline" phx-click={hide}>
                Cancel
              </.button>
              <.button phx-click={hide}>Confirm</.button>
            </div>
          </:footer>
        </.dialog>
      </.demo_section>

      <.demo_section title="Dialog Title Options" id="dialog-title-options">
        <div class="flex flex-wrap gap-3">
          <.dialog id="demo-title" size="md" title="Edit profile">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>With title</.button>
            </:trigger>

            <p class="text-sm text-muted-foreground">
              The built-in title keeps the header aligned with the close button.
            </p>
            <:footer :let={%{hide: hide}}>
              <div class="flex justify-end gap-2">
                <.button variant="outline" phx-click={hide}>Cancel</.button>
                <.button phx-click={hide}>Save</.button>
              </div>
            </:footer>
          </.dialog>

          <.dialog
            id="demo-no-close"
            size="md"
            title="Review order"
            show_close={false}
          >
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
        </div>
      </.demo_section>

      <.demo_section title="Scrollable Body with Footer" id="dialog-scrollable">
        <.dialog id="demo-scroll" size="lg" title="Recent activity">
          <:trigger :let={attr}>
            <.button variant="outline" {attr}>Scrollable dialog</.button>
          </:trigger>

          <div class="space-y-4">
            <p :for={index <- 1..12} class="text-sm text-muted-foreground">
              Activity #{index}: This dialog body scrolls automatically when the content grows taller than the viewport.
            </p>
          </div>

          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end gap-2">
              <.button variant="outline" phx-click={hide}>Close</.button>
              <.button phx-click={hide}>Save changes</.button>
            </div>
          </:footer>
        </.dialog>
      </.demo_section>

      <.demo_section title="Dialog Sizes" id="dialog-sizes">
        <div class="flex flex-wrap gap-3">
          <.dialog id="demo-sm" size="sm" title="Small dialog">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Small</.button>
            </:trigger>

            <p class="text-sm">This is a small dialog.</p>
            <:footer :let={%{hide: hide}}>
              <div class="flex justify-end">
                <.button size="sm" phx-click={hide}>
                  Close
                </.button>
              </div>
            </:footer>
          </.dialog>

          <.dialog id="demo-lg" size="lg" title="Large dialog">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Large</.button>
            </:trigger>

            <p class="text-sm">This is a large dialog with more room for content.</p>
            <:footer :let={%{hide: hide}}>
              <div class="flex justify-end">
                <.button phx-click={hide}>
                  Close
                </.button>
              </div>
            </:footer>
          </.dialog>

          <.dialog id="demo-xl" size="xl" title="Extra large dialog">
            <:trigger :let={attr}>
              <.button variant="outline" {attr}>Extra Large</.button>
            </:trigger>

            <p class="text-sm">This is an extra large dialog for complex content.</p>
            <:footer :let={%{hide: hide}}>
              <div class="flex justify-end">
                <.button phx-click={hide}>
                  Close
                </.button>
              </div>
            </:footer>
          </.dialog>
        </div>
      </.demo_section>

      <.demo_section title="Alert Dialog" id="alert-dialog">
        <.dialog id="demo-alert" alert={true} size="sm" title="Are you sure?">
          <:trigger :let={attr}>
            <.button variant="destructive" {attr}>Delete Item</.button>
          </:trigger>

          <div class="space-y-3">
            <p class="text-sm text-muted-foreground">
              This action cannot be undone. This will permanently delete the item.
            </p>
          </div>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end gap-2">
              <.button variant="outline" phx-click={hide}>
                Cancel
              </.button>
              <.button variant="destructive" phx-click={hide}>
                Delete
              </.button>
            </div>
          </:footer>
        </.dialog>
      </.demo_section>
    </section>
    """
  end

  def dialog_basic_demo(assigns) do
    ~H"""
    <.demo_section title="Basic Dialog Demo" id="dialog-basic-demo">
      <.dialog id="demo-dialog" size="md" title="Dialog Title">
        <:trigger :let={attr}>
          <.button {attr}>Open Dialog</.button>
        </:trigger>

        <div class="space-y-4">
          <p class="text-sm text-muted-foreground">
            This is a demonstration of the PUI dialog component.
          </p>
          <p class="text-sm text-muted-foreground">
            Dialogs are useful for confirmations, forms, and complex interactions that require user attention.
          </p>
        </div>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button phx-click={hide}>Confirm</.button>
          </div>
        </:footer>
      </.dialog>
    </.demo_section>
    """
  end

  def dialog_scroll_demo(assigns) do
    ~H"""
    <.demo_section title="Scrollable Dialog Demo" id="dialog-scroll-demo">
      <.dialog id="demo-scroll-docs" size="lg" title="Recent activity">
        <:trigger :let={attr}>
          <.button variant="outline" {attr}>Open scrollable dialog</.button>
        </:trigger>

        <div class="space-y-4">
          <p :for={index <- 1..12} class="text-sm text-muted-foreground">
            Activity #{index}: The body scrolls while the title and footer stay visible.
          </p>
        </div>

        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Close</.button>
            <.button phx-click={hide}>Save changes</.button>
          </div>
        </:footer>
      </.dialog>
    </.demo_section>
    """
  end

  def dialog_sizes_demo(assigns) do
    ~H"""
    <.demo_section title="Dialog Sizes Demo" id="dialog-sizes-demo">
      <div class="flex flex-wrap gap-3">
        <.dialog id="demo-sm" size="sm" title="Small dialog">
          <:trigger :let={attr}>
            <.button variant="outline" {attr}>Small</.button>
          </:trigger>
          <p class="text-sm">This is a small dialog.</p>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end">
              <.button size="sm" phx-click={hide}>Close</.button>
            </div>
          </:footer>
        </.dialog>

        <.dialog id="demo-lg" size="lg" title="Large dialog">
          <:trigger :let={attr}>
            <.button variant="outline" {attr}>Large</.button>
          </:trigger>
          <p class="text-sm">This is a large dialog with more room for content.</p>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end">
              <.button phx-click={hide}>Close</.button>
            </div>
          </:footer>
        </.dialog>

        <.dialog id="demo-xl" size="xl" title="Extra large dialog">
          <:trigger :let={attr}>
            <.button variant="outline" {attr}>Extra Large</.button>
          </:trigger>
          <p class="text-sm">This is an extra large dialog for complex content.</p>
          <:footer :let={%{hide: hide}}>
            <div class="flex justify-end">
              <.button phx-click={hide}>Close</.button>
            </div>
          </:footer>
        </.dialog>
      </div>
    </.demo_section>
    """
  end

  def dialog_alert_demo(assigns) do
    ~H"""
    <.demo_section title="Alert Dialog Demo" id="dialog-alert-demo">
      <.dialog id="demo-alert" alert={true} size="sm" title="Are you sure?">
        <:trigger :let={attr}>
          <.button variant="destructive" {attr}>Delete Item</.button>
        </:trigger>

        <div class="space-y-3">
          <p class="text-sm text-muted-foreground">
            This action cannot be undone. This will permanently delete the item.
          </p>
        </div>
        <:footer :let={%{hide: hide}}>
          <div class="flex justify-end gap-2">
            <.button variant="outline" phx-click={hide}>Cancel</.button>
            <.button variant="destructive" phx-click={hide}>Delete</.button>
          </div>
        </:footer>
      </.dialog>
    </.demo_section>
    """
  end

  def dropdown_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Dropdown" id="basic-dropdown">
        <.menu_button>
          Actions
          <:item>Edit</:item>
          <:item>Duplicate</:item>
          <:item>Archive</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="With Shortcuts" id="shortcuts">
        <.menu_button>
          File
          <:item shortcut="⌘N">New File</:item>
          <:item shortcut="⌘O">Open</:item>
          <:item shortcut="⌘S">Save</:item>
          <:item shortcut="⇧⌘S">Save As</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="Destructive Actions" id="destructive-dropdown">
        <.menu_button>
          Manage
          <:item>Settings</:item>
          <:item>Export Data</:item>
          <:item variant="destructive">Delete Account</:item>
        </.menu_button>
      </.demo_section>

      <.demo_section title="Button Variants" id="dropdown-variants">
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
      </.demo_section>
    </section>
    """
  end

  def dropdown_basic_demo(assigns) do
    ~H"""
    <.demo_section title="Basic Dropdown Demo" id="dropdown-basic-demo">
      <.menu_button>
        Actions
        <:item>Edit</:item>
        <:item>Duplicate</:item>
        <:item>Archive</:item>
      </.menu_button>
    </.demo_section>
    """
  end

  def dropdown_shortcuts_demo(assigns) do
    ~H"""
    <.demo_section title="Shortcut Menu Demo" id="dropdown-shortcuts-demo">
      <.menu_button>
        File
        <:item shortcut="⌘N">New File</:item>
        <:item shortcut="⌘O">Open</:item>
        <:item shortcut="⌘S">Save</:item>
        <:item shortcut="⇧⌘S">Save As</:item>
      </.menu_button>
    </.demo_section>
    """
  end

  def dropdown_destructive_demo(assigns) do
    ~H"""
    <.demo_section title="Destructive Dropdown Demo" id="dropdown-destructive-demo">
      <.menu_button>
        Manage
        <:item>Settings</:item>
        <:item>Export Data</:item>
        <:item variant="destructive">Delete Account</:item>
      </.menu_button>
    </.demo_section>
    """
  end

  def dropdown_variants_demo(assigns) do
    ~H"""
    <.demo_section title="Dropdown Variant Demo" id="dropdown-variants-demo">
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
    </.demo_section>
    """
  end

  def getting_started_quick_demo(assigns) do
    ~H"""
    <.demo_section title="Quick Example" id="getting-started-quick-demo">
      <div class="flex flex-wrap items-center gap-3">
        <.button>Primary Button</.button>
        <.button variant="secondary">Secondary</.button>
        <.button variant="outline">Outline</.button>
      </div>
      <div class="mt-4 max-w-sm">
        <.input id="quick-input" name="quick" label="Sample Input" placeholder="Type here..." />
      </div>
    </.demo_section>
    """
  end

  def loading_topbar_demo(assigns) do
    ~H"""
    <.demo_section title="Loading Demo" id="loading-topbar-demo">
      <p class="text-sm text-muted-foreground">
        The loading topbar is already active on this page. Navigate between docs pages to see it in action at the top of the screen.
      </p>
    </.demo_section>
    """
  end

  def container_card_demo(assigns) do
    ~H"""
    <.demo_section title="Card Demo" id="container-card-demo">
      <PUI.Container.card class="max-w-md">
        <PUI.Container.card_header>
          <PUI.Container.card_title>Card Title</PUI.Container.card_title>
          <PUI.Container.card_description>
            This is a card description.
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
    </.demo_section>
    """
  end

  def container_card_action_demo(assigns) do
    ~H"""
    <.demo_section title="Card Action Demo" id="container-card-action-demo">
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
            <div class="flex items-center gap-3 py-2">
              <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                A
              </div>
              <div>
                <p class="text-sm font-medium">Alice</p>
                <p class="text-xs text-muted-foreground">alice@example.com</p>
              </div>
            </div>
            <div class="flex items-center gap-3 py-2">
              <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                B
              </div>
              <div>
                <p class="text-sm font-medium">Bob</p>
                <p class="text-xs text-muted-foreground">bob@example.com</p>
              </div>
            </div>
          </div>
        </PUI.Container.card_content>
      </PUI.Container.card>
    </.demo_section>
    """
  end

  def headless_unstyled_demo(assigns) do
    ~H"""
    <.demo_section title="Unstyled Menu Demo" id="headless-unstyled-demo">
      <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
        <div class="flex flex-wrap items-start gap-4">
          <.button
            variant="unstyled"
            class="inline-flex items-center rounded-xl bg-zinc-950 px-4 py-2 text-sm font-medium text-white shadow-sm transition-colors hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200"
          >
            Custom Trigger
          </.button>

          <.menu_button
            variant="unstyled"
            class="inline-flex items-center gap-2 rounded-xl border border-primary/30 bg-primary/10 px-4 py-2 text-sm font-medium text-primary transition-colors hover:bg-primary/15"
            content_class="aria-hidden:hidden block min-w-48 rounded-xl border border-border bg-background p-1 shadow-xl"
          >
            Custom Menu
            <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
              <.icon name="hero-user" class="size-4" /> Profile
            </:item>
            <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-foreground transition-colors hover:bg-accent">
              <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
            </:item>
            <:item class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-destructive transition-colors hover:bg-destructive/10">
              <.icon name="hero-trash" class="size-4" /> Delete
            </:item>
          </.menu_button>
        </div>

        <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
          <p class="font-medium text-foreground">What PUI still handles</p>
          <ul class="mt-3 space-y-2">
            <li>ARIA attributes and keyboard navigation</li>
            <li>Popover positioning, dismissal, and focus behavior</li>
            <li>Slot-based composition for items and triggers</li>
          </ul>
        </div>
      </div>
    </.demo_section>
    """
  end

  def headless_popover_demo(assigns) do
    ~H"""
    <.demo_section title="Low-level Popover Demo" id="headless-popover-demo">
      <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_18rem]">
        <.popover_base
          id="docs-headless-popover"
          class="w-fit"
          phx-hook="PUI.Popover"
          data-placement="bottom-start"
        >
          <:trigger class="inline-flex items-center gap-2 rounded-xl border border-border bg-background px-4 py-2 text-sm font-medium text-foreground shadow-sm transition-colors hover:bg-accent">
            <.icon name="hero-code-bracket" class="size-4" /> Open custom popover
          </:trigger>
          <:popup class="aria-hidden:hidden block w-72 rounded-2xl border border-border bg-background p-4 shadow-xl">
            <div class="space-y-3">
              <span class="inline-flex rounded-full bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
                Level 1
              </span>
              <h3 class="text-sm font-semibold text-foreground">Low-level hook example</h3>
              <p class="text-sm text-muted-foreground">
                This example uses <code>popover_base</code>
                directly so you control the trigger markup, popup container, and every utility class yourself.
              </p>
            </div>
          </:popup>
        </.popover_base>

        <div class="rounded-xl border border-dashed border-border bg-muted/20 p-4 text-sm text-muted-foreground">
          <p class="font-medium text-foreground">When to use this</p>
          <ul class="mt-3 space-y-2">
            <li>Building a custom design system on top of PUI behavior</li>
            <li>Reusing Floating UI positioning with your own markup</li>
            <li>Creating bespoke popovers, menus, or tooltips</li>
          </ul>
        </div>
      </div>
    </.demo_section>
    """
  end

  def popover_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Basic Popover" id="basic-popover">
        <.popover_base
          id="demo-popover"
          class="w-fit"
          phx-hook="PUI.Popover"
          data-placement="bottom"
        >
          <:trigger class="inline-flex h-9 items-center justify-center gap-2 whitespace-nowrap rounded-md border border-input bg-transparent px-4 py-2 text-sm font-medium shadow-xs transition-[color,box-shadow] hover:bg-accent hover:text-accent-foreground">
            Show Popover
          </:trigger>
          <:popup class="aria-hidden:hidden block min-w-[250px] rounded-md border border-border bg-popover p-4 text-popover-foreground shadow-md z-50">
            <div class="p-4 space-y-2 w-64">
              <h3 class="font-semibold text-sm">Popover Title</h3>
              <p class="text-sm text-muted-foreground">
                This is a popover with some helpful content. Click the button again to close.
              </p>
            </div>
          </:popup>
        </.popover_base>
      </.demo_section>
    </section>
    """
  end

  def tooltip_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Tooltip Placements" id="tooltip-placements">
        <div class="flex flex-wrap items-center gap-6">
          <.tooltip placement="top">
            <.button variant="outline" size="sm">Top</.button>
            <:tooltip>Tooltip on top</:tooltip>
          </.tooltip>
          <.tooltip placement="bottom">
            <.button variant="outline" size="sm">Bottom</.button>
            <:tooltip>Tooltip on bottom</:tooltip>
          </.tooltip>
          <.tooltip placement="left">
            <.button variant="outline" size="sm">Left</.button>
            <:tooltip>Tooltip on left</:tooltip>
          </.tooltip>
          <.tooltip placement="right">
            <.button variant="outline" size="sm">Right</.button>
            <:tooltip>Tooltip on right</:tooltip>
          </.tooltip>
        </div>
      </.demo_section>

      <.demo_section title="Rich Tooltip" id="rich-tooltip">
        <.tooltip id="docs-rich-tooltip" placement="bottom">
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
      </.demo_section>
    </section>
    """
  end

  def alert_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Default Alert" id="default-alert">
        <.alert>
          <:icon><.icon name="hero-information-circle" class="size-5" /></:icon>
          <:title>Heads up!</:title>
          <:description>You can add components to your app using the CLI.</:description>
        </.alert>
      </.demo_section>

      <.demo_section title="Destructive Alert" id="destructive-alert">
        <.alert variant="destructive">
          <:icon><.icon name="hero-exclamation-triangle" class="size-5" /></:icon>
          <:title>Error</:title>
          <:description>Something went wrong. Please try again later.</:description>
        </.alert>
      </.demo_section>

      <.demo_section title="Custom Content" id="custom-alert">
        <.alert>
          <div class="flex items-center gap-3">
            <.icon name="hero-check-circle" class="size-5 text-green-500" />
            <div>
              <p class="font-semibold text-sm">Success!</p>
              <p class="text-sm text-muted-foreground">Your changes have been saved successfully.</p>
            </div>
          </div>
        </.alert>
      </.demo_section>
    </section>
    """
  end

  def flash_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Send Toast" id="send-toast">
        <div class="space-y-6">
          <div class="flex flex-wrap items-center gap-2">
            <span class="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Position
            </span>
            <div class="flex flex-wrap gap-1.5">
              <button
                :for={
                  position <- ~w(top-left top-center top-right bottom-left bottom-center bottom-right)
                }
                type="button"
                phx-click="select_flash_position"
                phx-value-position={position}
                class={[
                  "px-3 py-1 text-xs font-medium rounded-full transition-all",
                  position == @flash_position &&
                    "bg-primary text-primary-foreground shadow-sm",
                  position != @flash_position &&
                    "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground"
                ]}
              >
                {position}
              </button>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <.button phx-click="send_toast">
              <.icon name="hero-bell" class="size-4 mr-2" /> Send Toast
            </.button>
            <p class="text-sm text-muted-foreground self-center">
              Position: {@flash_position}. Count: {@toast_count}
            </p>
          </div>
        </div>
      </.demo_section>
    </section>
    """
  end

  def container_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Card" id="card-demo">
        <PUI.Container.card class="max-w-md">
          <PUI.Container.card_header>
            <PUI.Container.card_title>Card Title</PUI.Container.card_title>
            <PUI.Container.card_description>
              This is a card description.
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
      </.demo_section>

      <.demo_section title="Card with Action" id="card-action-demo">
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
              <div class="flex items-center gap-3 py-2">
                <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                  A
                </div>
                <div>
                  <p class="text-sm font-medium">Alice</p>
                  <p class="text-xs text-muted-foreground">alice@example.com</p>
                </div>
              </div>
              <div class="flex items-center gap-3 py-2">
                <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center text-sm font-medium text-primary">
                  B
                </div>
                <div>
                  <p class="text-sm font-medium">Bob</p>
                  <p class="text-xs text-muted-foreground">bob@example.com</p>
                </div>
              </div>
            </div>
          </PUI.Container.card_content>
        </PUI.Container.card>
      </.demo_section>
    </section>
    """
  end

  def loading_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Loading Topbar" id="loading-demo">
        <p class="text-sm text-muted-foreground">
          The loading topbar is already active on this page! Navigate between docs pages to see it in action.
          Look at the top of the page during navigation.
        </p>
      </.demo_section>
    </section>
    """
  end

  def progress_badges_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <h2 id="interactive-demo" class="text-2xl font-semibold text-foreground">
        Interactive Demo
      </h2>

      <.demo_section title="Progress Bar" id="progress-demo">
        <div class="space-y-4 max-w-md">
          <.progress value={@progress_value} />
          <div class="flex items-center gap-3">
            <input
              type="range"
              min="0"
              max="100"
              value={@progress_value}
              phx-change="update_progress"
              name="value"
              class="flex-1"
            />
            <span class="text-sm font-mono text-muted-foreground w-12 text-right">
              {trunc(@progress_value)}%
            </span>
          </div>
        </div>
      </.demo_section>

      <.demo_section title="Badges" id="badges-demo">
        <div class="flex flex-wrap items-center gap-3">
          <.badge>Default</.badge>
          <.badge variant="secondary">Secondary</.badge>
          <.badge variant="destructive">Destructive</.badge>
          <.badge variant="outline">Outline</.badge>
        </div>
      </.demo_section>
    </section>
    """
  end

  def getting_started_demo(assigns) do
    ~H"""
    <section class="space-y-8">
      <.demo_section title="Quick Example" id="quick-example">
        <div class="flex flex-wrap items-center gap-3">
          <.button>Primary Button</.button>
          <.button variant="secondary">Secondary</.button>
          <.button variant="outline">Outline</.button>
        </div>
        <div class="mt-4 max-w-sm">
          <.input id="quick-input" name="quick" label="Sample Input" placeholder="Type here..." />
        </div>
      </.demo_section>
    </section>
    """
  end

  attr :title, :string, required: true
  attr :id, :string, required: true
  slot :inner_block, required: true

  defp demo_section(assigns) do
    ~H"""
    <div class="rounded-xl border border-border bg-background shadow-sm overflow-visible" id={@id}>
      <div class="rounded-t-xl bg-muted/30 px-5 py-3 border-b border-border">
        <h3 class="text-sm font-medium text-foreground">{@title}</h3>
      </div>
      <div class="rounded-b-xl p-6 bg-background overflow-visible">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
