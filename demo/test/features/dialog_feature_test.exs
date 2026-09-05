defmodule AppWeb.DialogFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "dialogs open and close with accessible labeling", %{session: session} do
    session
    |> visit("/__test__/components/dialog")
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
    |> click(button("Open Dialog"))
    |> assert_has(css("#server-dialog-content[role='dialog'][aria-label='Harness dialog']"))
    |> click(button("Close Dialog"))
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
  end

  feature "dialog select can reopen after changing the selected category", %{session: session} do
    session
    |> visit("/__test__/components/dialog")
    |> click(button("Open Dialog"))
    |> click(css("#dialog-select-trigger"))
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const popup = document.querySelector("#dialog-select-listbox");
        const option = Array.from(
          popup?.querySelectorAll("[role='option']") || []
        ).find((item) => item.textContent.trim() === "Gamma");

        const state = {
          ariaHidden: popup?.getAttribute("aria-hidden"),
          strategy: popup?.dataset.floatingStrategy,
          hasOption: Boolean(option)
        };

        if (state.ariaHidden === "false" && state.strategy === "fixed" && option) {
          option.click();
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 50) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 10);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaHidden"] == "false"
        assert state["strategy"] == "fixed"
        assert state["hasOption"]
      end
    )
    |> assert_has(css("#dialog-select-trigger", text: "Gamma"))
    |> click(css("#dialog-select-trigger"))
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const popup = document.querySelector("#dialog-select-listbox");
        const state = {
          ariaHidden: popup?.getAttribute("aria-hidden"),
          strategy: popup?.dataset.floatingStrategy
        };

        if (state.ariaHidden === "false" && state.strategy === "fixed") {
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 50) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 10);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaHidden"] == "false"
        assert state["strategy"] == "fixed"
      end
    )
  end

  feature "closing a dialog with Escape does not corrupt inactive dialog", %{session: session} do
    session
    |> visit("/__test__/components/dialog")
    # Verify both dialogs are initially hidden
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
    |> assert_has(css("#second-server-dialog-content[hidden]", visible: false))
    # Open first dialog
    |> click(button("Open Dialog"))
    |> assert_has(css("#server-dialog-content:not([hidden])", visible: true))
    # Close first dialog with Escape key
    |> send_keys([:escape])
    |> assert_has(css("#server-dialog-content[hidden]", visible: false))
    # Open second dialog - should be fully visible and NOT corrupted with client hidden attribute
    |> click(button("Open Second Dialog"))
    |> assert_has(css("#second-server-dialog-content:not([hidden])", visible: true))
    # Close second dialog with Escape key
    |> send_keys([:escape])
    |> assert_has(css("#second-server-dialog-content[hidden]", visible: false))
    # Re-open first dialog - should be fully visible
    |> click(button("Open Dialog"))
    |> assert_has(css("#server-dialog-content:not([hidden])", visible: true))
  end
end
