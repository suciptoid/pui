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
      header_id_prefix: ""
    ]
  ]

  def render(markdown, assigns) do
    case MDEx.to_heex(markdown,
           Keyword.merge(@mdex_options,
             assigns: assigns,
             syntax_highlight: [
               engine: :lumis,
               opts: [formatter: {:html_inline, theme: "github_light"}]
             ]
           )
         ) do
      {:ok, rendered} -> rendered
      {:error, error} -> raise error
    end
  end
end
