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
end
