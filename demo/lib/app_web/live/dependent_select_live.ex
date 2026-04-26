defmodule AppWeb.Live.DependentSelectLive do
  @moduledoc false
  use AppWeb, :live_view
  use PUI

  @account_options %{
    "income" => [{"salary", "Salary"}, {"bonus", "Bonus"}],
    "expense" => [{"grocery", "Grocery"}, {"bill", "Bill"}, {"transport", "Transport"}]
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dependent Select Harness")
     |> assign(:mode, nil)
     |> assign(:account_options, [])
     |> assign(:mode_value, nil)
     |> assign(:account_value, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section id="dependent-select-harness" class="space-y-6 p-8">
        <h1 id="harness-title" class="text-2xl font-semibold">Dependent Select Harness</h1>

        <.form id="dependent-form" for={%{}} phx-change="mode_changed" class="max-w-md space-y-4">
          <.select
            id="mode-select"
            name="mode"
            value={@mode_value}
            label="Mode"
            placeholder="Select a mode"
            options={[{"income", "Income"}, {"expense", "Expense"}]}
          />

          <.select
            id="account-select"
            name="account"
            value={@account_value}
            label="Account"
            placeholder="Select an account"
            options={@account_options}
          />
        </.form>

        <div id="selection-summary">
          <p id="mode-summary">Mode: {@mode_value || "none"}</p>
          <p id="account-summary">Account: {@account_value || "none"}</p>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("mode_changed", params, socket) do
    mode = Map.get(params, "mode")
    account = Map.get(params, "account")

    new_options = Map.get(@account_options, mode, [])

    account_value =
      cond do
        mode != socket.assigns.mode -> nil
        true -> account
      end

    {:noreply,
     socket
     |> assign(:mode, mode)
     |> assign(:mode_value, mode)
     |> assign(:account_options, new_options)
     |> assign(:account_value, account_value)}
  end
end
