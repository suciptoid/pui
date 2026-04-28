defmodule AppWeb.DatePickerFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "single date picker selects a date and closes the popup", %{session: session} do
    Process.sleep(800)

    session
    |> visit("/__test__/components/date-picker")
    |> assert_has(css("label[for='harness-date-picker-input']"))
    |> assert_has(css("#harness-date-picker-day-2026-04-18", visible: false))
    |> assert_has(
      css(
        "#harness-date-picker-trigger[aria-controls='harness-date-picker-popover'][aria-expanded='false']"
      )
    )
    |> assert_has(css("#harness-date-picker-trigger", text: "Pick a date"))
    |> execute_script(~s|document.querySelector("#harness-date-picker-trigger").click()|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const trigger = document.querySelector("#harness-date-picker-trigger");
        const popup = document.querySelector("#harness-date-picker-popover");
        const state = {
          ariaExpanded: trigger?.getAttribute("aria-expanded"),
          ariaHidden: popup?.getAttribute("aria-hidden"),
          display: popup ? getComputedStyle(popup).display : "",
          visibility: popup ? getComputedStyle(popup).visibility : "",
          text: popup?.textContent.trim() || ""
        };

        if (state.ariaExpanded === "true" || attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaExpanded"] == "true", inspect(state)
        assert state["ariaHidden"] == "false", inspect(state)
      end
    )
    |> click(css("#harness-date-picker-day-2026-04-18"))
    |> assert_has(css("#date-picker-value", text: "Selected: 2026-04-18"))
    |> assert_has(css("#harness-date-picker-trigger", text: "Apr 18, 2026"))
  end

  feature "range picker renders two months and submits both selected dates", %{session: session} do
    Process.sleep(800)

    session
    |> visit("/__test__/components/date-picker")
    |> assert_has(css("label[for='harness-range-picker-from-input']"))
    |> assert_has(css("#harness-range-picker-day-2026-04-20", visible: false))
    |> assert_has(css("#harness-range-picker-day-2026-05-10", visible: false))
    |> execute_script(~s|document.querySelector("#harness-range-picker-trigger").click()|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      let attempts = 0;

      const poll = () => {
        const trigger = document.querySelector("#harness-range-picker-trigger");
        const popup = document.querySelector("#harness-range-picker-popover");
        const state = {
          ariaExpanded: trigger?.getAttribute("aria-expanded"),
          ariaHidden: popup?.getAttribute("aria-hidden"),
          display: popup ? getComputedStyle(popup).display : "",
          visibility: popup ? getComputedStyle(popup).visibility : "",
          text: popup?.textContent.trim() || ""
        };

        if (state.ariaExpanded === "true" || attempts++ > 100) {
          done(JSON.stringify(state));
          return;
        }

        window.setTimeout(poll, 20);
      };

      poll();
      """,
      fn result ->
        state = Jason.decode!(result)
        assert state["ariaExpanded"] == "true", inspect(state)
        assert state["ariaHidden"] == "false", inspect(state)
      end
    )
    |> execute_script(~s|document.querySelector("#harness-range-picker-day-2026-04-20").click()|)
    |> execute_script_async(
      """
      const done = arguments[arguments.length - 1];
      window.setTimeout(done, 250);
      """,
      fn _ -> :ok end
    )
    |> execute_script(~s|document.querySelector("#harness-range-picker-day-2026-05-10").click()|)
    |> assert_has(css("#range-picker-value", text: "Range: 2026-04-20 / 2026-05-10"))
    |> assert_has(css("#harness-range-picker-trigger", text: "Apr 20, 2026 - May 10, 2026"))
  end
end
