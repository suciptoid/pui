defmodule AppWeb.AccordionDocsFeatureTest do
  use AppWeb.FeatureCase, async: false

  feature "accordion docs render single-open, multiple-open, and headless demos", %{
    session: session
  } do
    session
    |> visit("/docs/accordion")
    |> assert_has(css("article", text: "Single Open Accordion"))
    |> assert_has(css("article", text: "Multiple Open Accordion"))
    |> assert_has(css("article", text: "Headless Accordion Demo"))
    |> assert_has(css("#accordion-single-demo details[open] summary", text: "How do I reset my password?"))
    |> assert_has(css("#accordion-multiple-demo summary", text: "Notification Settings"))
    |> assert_has(css("#accordion-multiple-demo summary", text: "Privacy & Security"))
    |> assert_has(css("#accordion-headless-demo-card", text: "Bring your own layout"))
  end
end
