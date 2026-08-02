defmodule AppWeb.IconsDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "icons docs render semantic icons and provider guidance", %{session: session} do
    session
    |> visit("/docs/icons")
    |> assert_has(css("h1", text: "Icons"))
    |> assert_has(css("#icons-demo"))
    |> assert_has(css("#icons-slot-demo"))
    |> assert_has(css("[data-icon-provider]"))
    |> assert_has(css("h2", text: "Default provider"))
    |> assert_has(css("h2", text: "Configure a provider"))
    |> assert_has(css("h2", text: "Lucide and Tabler"))
    |> assert_has(css("h2", text: "Application-owned icons"))
  end
end
