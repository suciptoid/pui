defmodule AppWeb.DocsMarkdown do
  @moduledoc """
  Renders docs markdown with MDEx + HEEx support.

  This allows docs pages to embed Phoenix components directly from markdown
  using fully qualified component tags such as
  `<AppWeb.DocsDemo.select_demo form={@form} />`.
  """
  use AppWeb, :html
  use MDEx
  use PUI

  @mdex_options [
    extension: [
      strikethrough: true,
      table: true,
      autolink: true,
      tasklist: true,
      header_id_prefix: "",
      phoenix_heex: true
    ],
    render: [unsafe: true]
  ]

  def render(markdown, assigns) do
    case MDEx.to_html(markdown, @mdex_options) do
      {:ok, html} ->
        case MDEx.to_heex(html, assigns: assigns) do
          {:ok, rendered} -> rendered
          {:error, error} -> raise error
        end

      {:error, error} ->
        raise error
    end
  end
end
