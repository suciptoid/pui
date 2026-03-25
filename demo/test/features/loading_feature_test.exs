defmodule AppWeb.LoadingFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "loading component mounts the topbar shell", %{session: session} do
    session
    |> visit("/__test__/components/loading")
    |> assert_has(css("#loadingbar", count: 1))
    |> assert_has(css("#loadingbar-progress"))
    |> assert_has(
      css("#loading-description", text: "Loading bar is mounted from the root layout.")
    )
  end
end
