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
    |> execute_script(~s|document.querySelector("#dialog-select-trigger").click()|)
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
    |> execute_script(~s|document.querySelector("#dialog-select-trigger").click()|)
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
end
