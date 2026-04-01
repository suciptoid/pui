defmodule AppWeb.TabsDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "tabs docs render client, server, and vertical demos", %{session: session} do
    session
    |> visit("/docs/tabs")
    |> assert_has(css("article", text: "Client-Controlled Tabs Demo"))
    |> assert_has(css("article", text: "Server-Controlled Tabs Demo"))
    |> assert_has(css("article", text: "Vertical Tabs Demo"))
    |> assert_has(css("#docs-tabs-client [role='tab'][aria-selected='true']", text: "Overview"))
    |> assert_has(css("#docs-tabs-demo-server [role='tab']", text: "Billing"))
    |> assert_has(css("#docs-tabs-demo-server-value", text: "Server active tab: overview"))
    |> assert_has(css("#tabs-vertical-demo [role='tablist'][aria-orientation='vertical']"))
  end
end
