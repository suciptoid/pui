defmodule AppWeb.LayoutAppFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "demo root opens the overview and exposes the component catalog", %{session: session} do
    session
    |> visit("/demo/")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("h1", text: "Overview"))
    |> assert_has(css("a[href='/demo/table']", text: "Table"))
  end

  feature "layout app demo renders a full-page shell", %{session: session} do
    session
    |> visit("/demo/overview")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("#demo-app-shell[data-collapsed='false']"))
    |> assert_has(css("h1", text: "Overview"))
    |> assert_has(css("#layout-overview-chart"))
    |> assert_has(css("a[href='/demo/chart']", text: "Chart"))
  end

  feature "layout chart page renders as a dedicated sidebar destination", %{session: session} do
    session
    |> visit("/demo/chart")
    |> assert_has(css("h1", text: "Chart"))
    |> assert_has(css("#layout-chart-primary"))
    |> assert_has(css("#layout-chart-secondary"))
    |> assert_has(
      css("a[href='/demo/chart'][aria-current='page'], a[href='/demo/chart']",
        text: "Chart"
      )
    )
  end

  feature "table page showcases styled and customizable data tables", %{session: session} do
    session
    |> visit("/demo/table")
    |> assert_has(css("#demo-app-shell"))
    |> assert_has(css("h1", text: "Table"))
    |> assert_has(css("#demo-table-projects", text: "PUI"))
    |> assert_has(css("#demo-table-custom-projects", text: "Keping"))
    |> assert_has(css("#demo-table-empty", text: "No projects yet"))
    |> assert_has(css("a[href='/docs/table']", text: "Table"))
  end

  feature "layout demo renders collapsed state from the app-owned cookie", %{session: session} do
    session
    |> visit("/demo/overview")
    |> assert_has(css("#demo-app-shell[data-collapsed='false']"))
    |> execute_script(
      ~s|document.cookie = "demo_sidebar_collapsed=true; Path=/; Max-Age=31536000; SameSite=Lax"|
    )
    |> visit("/demo/overview")
    |> assert_has(css("#demo-app-shell[data-collapsed='true']"))
  end
end
