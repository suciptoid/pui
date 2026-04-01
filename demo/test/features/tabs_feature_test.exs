defmodule AppWeb.TabsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "tabs harness exposes client and server controlled tabs", %{session: session} do
    session
    |> visit("/__test__/components/tabs")
    |> assert_has(css("#client-tabs [role='tablist'][aria-orientation='horizontal']"))
    |> assert_has(css("#client-tabs [role='tab'][aria-selected='true']", text: "Overview"))
    |> click(css("#server-tabs [role='tab'][data-value='settings']"))
    |> assert_has(css("#server-tabs [role='tab'][aria-selected='true']", text: "Settings"))
    |> assert_has(css("#server-tab-value", text: "Server active: settings"))
  end
end
