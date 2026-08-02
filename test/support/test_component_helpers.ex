defmodule PUI.TestComponentHelpers do
  def render_deprecated_component(module, function, assigns) do
    assigns = Map.put(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Phoenix.LiveViewTest.rendered_to_string()
  end
end
