defmodule App.Docs.Doc do
  @moduledoc """
  Struct representing a documentation page.

  Each doc is built from a markdown file in `priv/docs/` using NimblePublisher.
  """

  @enforce_keys [:id, :title, :description, :group, :order, :body]
  defstruct [:id, :title, :description, :group, :order, :body, :icon, toc: []]

  def build(filename, attrs, body) do
    id = filename |> Path.rootname() |> Path.basename()
    body = {:dynamic, body}
    toc = extract_toc(body)

    struct!(
      __MODULE__,
      [id: id, body: body, toc: toc] ++ Map.to_list(attrs)
    )
  end

  def render({:dynamic, markdown}, assigns) do
    AppWeb.DocsMarkdown.render(markdown, assigns)
  end

  def render(html, _assigns) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp extract_toc({:dynamic, markdown}), do: extract_toc_from_markdown(markdown)
  defp extract_toc(html) when is_binary(html), do: extract_toc_from_html(html)

  defp extract_toc_from_html(html) do
    ~r/<h([23])><a[^>]*id="([^"]*)"[^>]*><\/a>(.*?)<\/h\1>/s
    |> Regex.scan(html)
    |> Enum.map(fn [_, level, id, text] ->
      clean_text = Regex.replace(~r/<[^>]+>/, text, "") |> String.trim()
      %{level: String.to_integer(level), id: id, text: clean_text}
    end)
  end

  defp extract_toc_from_markdown(markdown) do
    markdown
    |> String.split("\n")
    |> Enum.reduce({[], false}, fn line, {entries, in_code_block?} ->
      trimmed = String.trim(line)
      heading = Regex.run(~r/^(##|###)\s+(.+?)\s*$/, trimmed)

      cond do
        String.starts_with?(trimmed, "```") ->
          {entries, !in_code_block?}

        in_code_block? ->
          {entries, in_code_block?}

        heading ->
          [_, hashes, text] = heading
          clean_text = text |> String.replace(~r/[*_`[\]()]/, "") |> String.trim()

          entry = %{
            level: String.length(hashes),
            id: slugify(clean_text),
            text: clean_text
          }

          {[entry | entries], in_code_block?}

        true ->
          {entries, in_code_block?}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/<[^>]+>/, "")
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
  end
end
