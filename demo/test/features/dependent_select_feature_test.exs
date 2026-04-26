defmodule AppWeb.DependentSelectFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dependent select updates account options when mode changes", %{session: session} do
    session
    |> visit("/__test__/components/dependent-select")
    |> assert_has(css("#dependent-select-harness"))
    |> assert_has(css("#mode-select-trigger", text: "Select a mode"))
    |> assert_has(css("#account-select-trigger", text: "Select an account"))
    |> assert_has(css("#mode-summary", text: "Mode: none"))
    |> assert_has(css("#account-summary", text: "Account: none"))
  end

  feature "selecting income mode populates income accounts", %{session: session} do
    session
    |> visit("/__test__/components/dependent-select")
    |> select_mode("income")
    |> assert_has(css("#mode-summary", text: "Mode: income"))
    |> assert_has(css("#account-summary", text: "Account: none"))
    |> assert_income_options_rendered()
    |> select_account("salary")
    |> assert_has(css("#account-summary", text: "Account: salary"))
  end

  feature "selecting expense mode populates expense accounts", %{session: session} do
    session
    |> visit("/__test__/components/dependent-select")
    |> select_mode("expense")
    |> assert_has(css("#mode-summary", text: "Mode: expense"))
    |> assert_expense_options_rendered()
    |> select_account("transport")
    |> assert_has(css("#account-summary", text: "Account: transport"))
  end

  feature "switching mode resets the account select", %{session: session} do
    session
    |> visit("/__test__/components/dependent-select")
    |> select_mode("income")
    |> select_account("salary")
    |> assert_has(css("#account-summary", text: "Account: salary"))
    |> select_mode("expense")
    |> assert_has(css("#mode-summary", text: "Mode: expense"))
    |> assert_has(css("#account-summary", text: "Account: none"))
    |> assert_expense_options_rendered()
  end

  feature "switching from expense to income changes the account options", %{session: session} do
    session
    |> visit("/__test__/components/dependent-select")
    |> select_mode("expense")
    |> select_account("bill")
    |> assert_has(css("#account-summary", text: "Account: bill"))
    |> select_mode("income")
    |> assert_has(css("#mode-summary", text: "Mode: income"))
    |> assert_has(css("#account-summary", text: "Account: none"))
    |> assert_income_options_rendered()
  end

  defp select_mode(session, value) do
    execute_script(
      session,
      """
      const el = document.querySelector('#mode-select');
      const trigger = document.querySelector('#mode-select-trigger');
      trigger && trigger.click();

      setTimeout(() => {
        const item = Array.from(el.querySelectorAll('[role="option"]'))
          .find(o => o.dataset.value === '#{value}');
        item && item.click();
      }, 50);
      """
    )

    # Wait for the LiveView to process the event and re-render
    Process.sleep(200)
    session
  end

  defp select_account(session, value) do
    execute_script(
      session,
      """
      const el = document.querySelector('#account-select');
      const trigger = document.querySelector('#account-select-trigger');
      trigger && trigger.click();

      setTimeout(() => {
        const item = Array.from(el.querySelectorAll('[role="option"]'))
          .find(o => o.dataset.value === '#{value}');
        item && item.click();
      }, 50);
      """
    )

    Process.sleep(200)
    session
  end

  defp assert_income_options_rendered(session) do
    execute_script_async(
      session,
      """
      const done = arguments[arguments.length - 1];
      const el = document.querySelector('#account-select');
      const items = el ? el.querySelectorAll('[role="option"]') : [];
      const values = Array.from(items).map(i => i.dataset.value);
      done(JSON.stringify(values));
      """,
      fn result ->
        values = Jason.decode!(result)
        assert values == ["salary", "bonus"]
      end
    )

    session
  end

  defp assert_expense_options_rendered(session) do
    execute_script_async(
      session,
      """
      const done = arguments[arguments.length - 1];
      const el = document.querySelector('#account-select');
      const items = el ? el.querySelectorAll('[role="option"]') : [];
      const values = Array.from(items).map(i => i.dataset.value);
      done(JSON.stringify(values));
      """,
      fn result ->
        values = Jason.decode!(result)
        assert values == ["grocery", "bill", "transport"]
      end
    )

    session
  end
end
