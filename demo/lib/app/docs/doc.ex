defmodule App.Docs.Doc do
  @moduledoc """
  Struct representing a documentation page.

  Each doc is built from a markdown file in `priv/docs/` using NimblePublisher.
  """

  @enforce_keys [:id, :title, :description, :group, :order, :body]
  defstruct [:id, :title, :description, :group, :order, :body, :icon, toc: []]

  def build(filename, attrs, body) do
    id = filename |> Path.rootname() |> Path.basename()

    toc = extract_toc(body)

    struct!(
      __MODULE__,
      [id: id, body: body, toc: toc] ++ Map.to_list(attrs)
    )
  end

  defp extract_toc(html) do
    ~r/<h([23])><a[^>]*id="([^"]*)"[^>]*><\/a>(.*?)<\/h\1>/s
    |> Regex.scan(html)
    |> Enum.map(fn [_, level, id, text] ->
      clean_text = Regex.replace(~r/<[^>]+>/, text, "") |> String.trim()
      %{level: String.to_integer(level), id: id, text: clean_text}
    end)
  end
end
