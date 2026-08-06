defmodule PUI.DatePickerTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import PUI.DatePicker

  describe "date_picker/1" do
    test "renders month and year selects by default" do
      html =
        render_component(&date_picker/1,
          id: "picker-default",
          name: "published_on",
          default_month: ~D[2026-04-01]
        )

      assert html =~ ~s(id="picker-default-month-select-0")
      assert html =~ ~s(id="picker-default-year-select-0")
      assert html =~ ~s(data-pui="calendar-month-select")
      assert html =~ ~s(data-pui="calendar-year-select")
      assert html =~ ~s(data-strategy="auto")
      refute html =~ ~s(<form class="contents")
    end

    test "supports the compact header mode" do
      html =
        render_component(&date_picker/1,
          id: "picker-compact",
          name: "published_on",
          default_month: ~D[2026-04-01],
          selectable_month: false
        )

      refute html =~ "picker-compact-month-select-0"
      refute html =~ "picker-compact-year-select-0"
      assert html =~ "April 2026"
    end

    test "disables dates outside min and max" do
      html =
        render_component(&date_picker/1,
          id: "picker-bounds",
          name: "delivery_date",
          default_month: ~D[2026-04-01],
          min: ~D[2026-04-10],
          max: ~D[2026-04-22]
        )

      assert html =~ ~r/id="picker-bounds-month-0-day-2026-04-09"[^>]*disabled/
      assert html =~ ~r/id="picker-bounds-month-0-day-2026-04-23"[^>]*disabled/
      assert html =~ ~s(id="picker-bounds-month-0-day-2026-04-15")
      assert html =~ ~r/<option value="3" disabled>\s*March\s*<\/option>/
      assert html =~ ~r/<option value="4" selected>\s*April\s*<\/option>/
      assert html =~ ~r/<option value="5" disabled>\s*May\s*<\/option>/
    end

    test "hides adjacent-month days when show_overlap is false" do
      html =
        render_component(&date_picker/1,
          id: "picker-hidden-overlap",
          name: "published_on",
          default_month: ~D[2026-04-01],
          show_overlap: false
        )

      refute html =~ ~s(id="picker-hidden-overlap-month-0-day-2026-05-01")
    end

    test "can show adjacent-month days and start weeks on sunday" do
      html =
        render_component(&date_picker/1,
          id: "picker-visible-overlap",
          name: "published_on",
          default_month: ~D[2026-04-01],
          week_start: :sunday,
          show_overlap: true
        )

      assert html =~ ~s(id="picker-visible-overlap-month-0-day-2026-03-29")
      assert html =~ ~s(id="picker-visible-overlap-month-0-day-2026-05-09")
    end

    test "renders footer slot content inside the popup" do
      html =
        render_component(
          fn assigns ->
            ~H"""
            <.date_picker id="picker-footer" name="reminder_at">
              <:footer>
                <span>Footer content</span>
              </:footer>
            </.date_picker>
            """
          end,
          %{}
        )

      assert html =~ "Footer content"
      assert html =~ "border-t border-border p-2"
    end
  end

  describe "range_picker/1" do
    test "does not show range indicators for adjacent-month days" do
      html =
        render_component(&range_picker/1,
          id: "range-visible-overlap",
          from_name: "trip_start",
          to_name: "trip_end",
          from_value: ~D[2026-03-30],
          to_value: ~D[2026-04-02],
          default_month: ~D[2026-04-01],
          number_of_months: 1,
          show_overlap: true
        )

      assert html =~ ~s(id="range-visible-overlap-month-0-day-2026-03-30")

      assert html =~
               ~r/id="range-visible-overlap-month-0-day-2026-03-30"[^>]*aria-selected="false"/
    end

    test "renders a selected two-month range with compact month headers" do
      html =
        render_component(&range_picker/1,
          id: "range-selected",
          from_name: "start_date",
          to_name: "end_date",
          from_value: ~D[2026-06-10],
          to_value: ~D[2026-06-20],
          default_month: ~D[2026-04-01],
          number_of_months: 2,
          selectable_month: false,
          week_start: :sunday,
          show_overlap: true
        )

      assert html =~ "June 2026"
      assert html =~ ~s(data-pui="range-start-value")
      assert html =~ ~s(data-pui="range-end-value")
      assert html =~ ~s(value="2026-06-10")
      assert html =~ ~s(value="2026-06-20")
      assert html =~ ~s(aria-label="Start of selected range, June 10, 2026")
      assert html =~ ~s(aria-label="End of selected range, June 20, 2026")
      assert html =~ ~s(data-pui="calendar-prev")
      assert html =~ ~s(data-pui="calendar-next")
    end
  end

  describe "clamp_visible_month/4" do
    test "clamps the first visible month for multi-month calendars" do
      assert clamp_visible_month("2026-06-01", nil, "2026-06-15", 2) == "2026-05-01"
      assert clamp_visible_month("2026-03-01", "2026-04-10", nil, 2) == "2026-04-01"
    end

    test "prefers a selected date over the default month" do
      assert resolve_visible_month("2026-04-01", ["2026-05-10"]) == "2026-05-01"
    end

    test "detects dates visible within a multi-month window" do
      assert visible_window_contains?("2026-06-01", "2026-07-15", 2)
      refute visible_window_contains?("2026-06-01", "2026-08-01", 2)
    end
  end

  describe "next_range_selection/3" do
    test "orders a completed range when the second click is earlier" do
      assert next_range_selection("2026-04-28", nil, "2026-04-01") ==
               {"2026-04-01", "2026-04-28"}
    end

    test "rejects same-day clicks so a range is never zero-length" do
      assert next_range_selection("2026-04-28", nil, "2026-04-28") ==
               {"2026-04-28", nil}
    end
  end

  describe "date value helpers" do
    test "normalizes supported date value types and rejects invalid input" do
      assert normalize_date_value(nil) == nil
      assert normalize_date_value("") == nil
      assert normalize_date_value(~D[2026-04-05]) == "2026-04-05"
      assert normalize_date_value(~N[2026-04-05 12:30:00]) == "2026-04-05"
      assert normalize_date_value(~U[2026-04-05 12:30:00Z]) == "2026-04-05"
      assert normalize_date_value(" 2026-04-05 ") == "2026-04-05"
      assert normalize_date_value("2026-04-05T12:30:00") == "2026-04-05"
      assert normalize_date_value("2026-04-05T12:30:00Z") == "2026-04-05"
      assert normalize_date_value("not-a-date") == nil

      assert_raise ArgumentError, ~r/expected ISO date value/, fn ->
        normalize_date!("not-a-date")
      end
    end

    test "formats single and range labels" do
      assert format_date_label(nil) == nil
      assert format_date_label("2026-04-05") == "Apr 05, 2026"
      assert format_range_label(nil, nil) == nil
      assert format_range_label("2026-04-05", nil) == "Apr 05, 2026"
      assert format_range_label("2026-04-05", "2026-04-10") == "Apr 05, 2026 - Apr 10, 2026"
    end

    test "checks visible windows and date bounds at their edges" do
      refute visible_window_contains?(nil, "2026-04-05", 1)
      refute visible_window_contains?("2026-04-01", nil, 1)
      assert visible_window_contains?("2026-04-01", "2026-04-30", 1)
      assert visible_window_contains?("2026-04-01", "2026-05-31", 2)
      refute visible_window_contains?("2026-04-01", "2026-06-01", 2)

      assert clamp_visible_month("2026-01-01", "2026-04-10", nil, 1) == "2026-04-01"
      assert clamp_visible_month("2026-12-01", nil, "2026-08-10", 2) == "2026-07-01"
      assert visible_month_allowed?("2026-04-01", "2026-04-01", "2026-06-30", 1)
      refute visible_month_allowed?("2026-03-01", "2026-04-01", "2026-06-30", 1)
      assert set_visible_month(2026, 3, 0, "2026-04-01", nil, 1) == "2026-04-01"
      assert within_bounds?(nil, nil, nil) == false
      assert within_bounds?("2026-04-10", "2026-04-01", "2026-04-30")
      refute within_bounds?("2026-03-31", "2026-04-01", nil)
      refute within_bounds?("2026-05-01", nil, "2026-04-30")
    end

    test "exposes month, selection, and style contracts" do
      assert month_name(1) == "January"
      assert month_name(12) == "December"
      assert visible_month_for_offset("2026-04-01", 2) == "2026-06-01"
      assert selection_completes_range?("2026-04-05", nil, "2026-04-06")
      refute selection_completes_range?(nil, nil, "2026-04-06")
      refute selection_completes_range?("2026-04-05", nil, "2026-04-05")
      assert hidden_input_style() =~ "position:absolute"
      assert trigger_classes("custom-trigger") |> Enum.member?("custom-trigger")
      assert content_classes("custom-content") |> Enum.member?("custom-content")
      assert nav_button_classes() =~ "disabled:opacity-40"
      assert header_select_classes() =~ "h-8"
    end
  end

  describe "DatePickerComponent lifecycle" do
    test "updates a single picker and handles navigation, selection, month, and year events" do
      assigns = %{
        id: "component-picker",
        mode: "single",
        value: nil,
        from_value: nil,
        to_value: nil,
        default_month: "2026-06-01",
        number_of_months: 2,
        min: "2026-06-01",
        max: "2028-12-31"
      }

      {:ok, socket} =
        PUI.DatePickerComponent.update(assigns, component_socket())

      assert socket.assigns.visible_month == "2026-06-01"
      assert length(socket.assigns.months) == 2

      {:noreply, socket} =
        PUI.DatePickerComponent.handle_event("navigate", %{"direction" => "next"}, socket)

      assert socket.assigns.visible_month == "2026-07-01"

      {:noreply, socket} =
        PUI.DatePickerComponent.handle_event("select", %{"date" => "2026-08-10"}, socket)

      assert socket.assigns.value == "2026-08-10"

      {:noreply, socket} =
        PUI.DatePickerComponent.handle_event(
          "select_month",
          %{"month" => "9", "offset" => "0"},
          socket
        )

      assert socket.assigns.visible_month == "2026-09-01"

      {:noreply, socket} =
        PUI.DatePickerComponent.handle_event(
          "select_year",
          %{"year" => "2027", "offset" => "0"},
          socket
        )

      assert socket.assigns.visible_month == "2027-09-01"

      {:noreply, unchanged} =
        PUI.DatePickerComponent.handle_event("select", %{"date" => "2029-01-01"}, socket)

      assert unchanged.assigns.value == socket.assigns.value
    end

    test "updates a range picker and rejects out-of-bounds ranges" do
      assigns = %{
        id: "range-component",
        mode: "range",
        value: nil,
        from_value: nil,
        to_value: nil,
        default_month: "2026-06-01",
        min: "2026-06-01",
        max: "2026-08-31"
      }

      {:ok, socket} =
        PUI.DatePickerComponent.update(assigns, component_socket())

      {:noreply, selected} =
        PUI.DatePickerComponent.handle_event(
          "select",
          %{"from" => "2026-06-10", "to" => "2026-06-20"},
          socket
        )

      assert selected.assigns.from_value == "2026-06-10"
      assert selected.assigns.to_value == "2026-06-20"

      {:noreply, unchanged} =
        PUI.DatePickerComponent.handle_event(
          "select",
          %{"from" => "2026-05-10", "to" => "2026-06-20"},
          selected
        )

      assert unchanged.assigns.from_value == selected.assigns.from_value
      assert unchanged.assigns.to_value == selected.assigns.to_value
    end
  end

  defp component_socket do
    %Phoenix.LiveView.Socket{
      assigns: %{__changed__: %{}, live_temp: %{}, lifecycle: %{}}
    }
  end
end
