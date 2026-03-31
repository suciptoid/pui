defmodule App.Docs do
  @moduledoc """
  Documentation context powered by NimblePublisher.

  Compiles markdown files from `priv/docs/` into Doc structs at build time.
  Markdown bodies are rendered through MDEx at request time so docs pages can
  embed Phoenix components inline.
  """

  alias App.Docs.Doc

  use NimblePublisher,
    build: Doc,
    from: Application.app_dir(:app, "priv/docs/**/*.md"),
    as: :docs,
    html_converter: App.Docs.MDExConverter

  @doc "Returns all documentation pages sorted by group and order."
  def all_docs, do: @docs |> Enum.sort_by(&{&1.group, &1.order})

  @doc "Returns a single doc by its slug/id."
  def get_doc!(id) do
    Enum.find(all_docs(), &(&1.id == id)) ||
      raise AppWeb.NotFoundError, "Doc #{id} not found"
  end

  @doc "Returns docs grouped by their group field."
  def grouped_docs do
    all_docs()
    |> Enum.group_by(& &1.group)
    |> Enum.sort_by(fn {group, _} -> group_order(group) end)
  end

  defp group_order("Getting Started"), do: 0
  defp group_order("Forms"), do: 1
  defp group_order("Actions"), do: 2
  defp group_order("Overlays"), do: 3
  defp group_order("Feedback"), do: 4
  defp group_order("Layout"), do: 5
  defp group_order("Data Display"), do: 6
  defp group_order(_), do: 99
end
