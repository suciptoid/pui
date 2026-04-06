defmodule AppWeb.SelectFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "select components support labeling, search, and selection", %{session: session} do
    session
    |> visit("/__test__/components/select")
    |> assert_has(css("label[for='harness-select-trigger']"))
    |> assert_has(
      css("#harness-select-trigger[role='combobox'][aria-controls='harness-select-listbox']")
    )
    |> assert_has(css("#harness-select-trigger", text: "Beta"))
    |> assert_has(css("#harness-select [role='searchbox']", visible: false))
    |> assert_has(css("label[for='long-harness-select-trigger']"))
    |> assert_has(css("label[for='scroll-harness-select-trigger']"))
    |> assert_has(css("#select-value", text: "Selected: beta"))
  end

  feature "long select keeps the selected option visible when opened", %{session: session} do
    session
    |> visit("/__test__/components/select")
    |> assert_has(css("#long-harness-select-trigger", text: "Item 30"))
    |> execute_script(~s|document.querySelector("#long-harness-select-trigger").click()|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const popup = document.querySelector("#long-harness-select-listbox");
        const viewport =
          popup?.querySelector("[data-pui='menu-viewport']") || popup;
        const selected = popup?.querySelector("[role='option'][aria-selected='true']");
        const viewportRect = viewport?.getBoundingClientRect();
        const selectedRect = selected?.getBoundingClientRect();
        const selectedVisible = Boolean(
          viewportRect &&
            selectedRect &&
            selectedRect.top >= viewportRect.top &&
            selectedRect.bottom <= viewportRect.bottom
        );

        const state = {
          ariaHidden: popup?.getAttribute("aria-hidden"),
          availableHeightVar:
            popup?.style.getPropertyValue("--pui-select-content-available-height").trim() || "",
          computedMaxHeight: popup ? getComputedStyle(popup).maxHeight : "",
          scrollTop: viewport?.scrollTop || 0,
          clientHeight: viewport?.clientHeight || 0,
          scrollHeight: viewport?.scrollHeight || 0,
          selectedLabel: selected?.textContent.trim() || null,
          selectedVisible
        };

        if (
          state.ariaHidden === "false" &&
          state.selectedLabel === "Item 30" &&
          state.availableHeightVar !== "" &&
          state.computedMaxHeight !== "" &&
          state.computedMaxHeight !== "none" &&
          state.scrollHeight > state.clientHeight &&
          state.scrollTop > 0 &&
          state.selectedVisible
        ) {
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaHidden"] == "false"
        assert state["selectedLabel"] == "Item 30"
        assert state["availableHeightVar"] != ""
        assert state["computedMaxHeight"] != ""
        assert state["scrollHeight"] > state["clientHeight"]
        assert state["scrollTop"] > 0
        assert state["selectedVisible"]
      end
    )
  end

  feature "select popup closes when the trigger scrolls out of view", %{session: session} do
    session
    |> visit("/__test__/components/select")
    |> assert_has(css("#scroll-harness-select-trigger", text: "Beta"))
    |> execute_script(~s|document.querySelector("#scroll-harness-select-trigger").click()|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const popup = document.querySelector("#scroll-harness-select-listbox");
        const state = {
          ariaHidden: popup?.getAttribute("aria-hidden"),
          strategy: popup?.dataset.floatingStrategy,
          referenceHidden: popup?.dataset.referenceHidden,
          visibility: popup ? getComputedStyle(popup).visibility : ""
        };

        if (
          state.ariaHidden === "false" &&
          state.strategy === "fixed" &&
          state.referenceHidden === "false" &&
          state.visibility === "visible"
        ) {
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaHidden"] == "false"
        assert state["strategy"] == "fixed"
        assert state["referenceHidden"] == "false"
        assert state["visibility"] == "visible"
      end
    )
    |> execute_script(
      ~s|const scrollbox = document.querySelector("#scroll-select-scrollbox"); scrollbox.scrollTop = scrollbox.scrollHeight;|
    )
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const trigger = document.querySelector("#scroll-harness-select-trigger");
        const popup = document.querySelector("#scroll-harness-select-listbox");
        const state = {
          ariaExpanded: trigger?.getAttribute("aria-expanded"),
          referenceHidden: popup?.dataset.referenceHidden,
          ariaHidden: popup?.getAttribute("aria-hidden"),
          display: popup ? getComputedStyle(popup).display : ""
        };

        if (
          state.ariaExpanded === "false" &&
          state.ariaHidden === "true" &&
          state.display === "none"
        ) {
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaExpanded"] == "false"
        assert state["ariaHidden"] == "true"
        assert state["display"] == "none"
      end
    )
    |> execute_script(~s|document.querySelector("#scroll-select-scrollbox").scrollTop = 0|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const trigger = document.querySelector("#scroll-harness-select-trigger");
        const popup = document.querySelector("#scroll-harness-select-listbox");
        const state = {
          ariaExpanded: trigger?.getAttribute("aria-expanded"),
          ariaHidden: popup?.getAttribute("aria-hidden"),
          display: popup ? getComputedStyle(popup).display : ""
        };

        if (
          state.ariaExpanded === "false" &&
          state.ariaHidden === "true" &&
          state.display === "none"
        ) {
          done(JSON.stringify(state));
          return;
        }

        if (attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaExpanded"] == "false"
        assert state["ariaHidden"] == "true"
        assert state["display"] == "none"
      end
    )
  end
end
