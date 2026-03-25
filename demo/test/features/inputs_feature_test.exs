defmodule AppWeb.InputsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "inputs page supports form input and switch semantics", %{session: session} do
    session
    |> visit("/__test__/components/input")
    |> fill_in(text_field("Full Name"), with: "Jane Doe")
    |> assert_has(css("#input-value", text: "Jane Doe"))
    |> assert_has(css("#email-switch[role='switch']"))
    |> assert_has(css("#terms-checkbox"))
  end
end
