defmodule AppWeb.InputsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "inputs page supports form input and switch semantics", %{session: session} do
    session
    |> visit("/inputs")
    |> fill_in(text_field("With Phoenix Form"), with: "Jane Doe")
    |> assert_has(css("#form-demo", text: "Jane Doe"))
    |> assert_has(css("input#switch-1[role='switch']"))
    |> assert_has(css("#demo-checkbox-1"))
  end
end
