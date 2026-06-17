defmodule AppWeb.DocsMarkdown do
  @moduledoc """
  Renders docs markdown with MDEx + HEEx support.

  This allows docs pages to embed Phoenix components directly from markdown
  using fully qualified component tags such as
  `<AppWeb.DocsDemo.select_demo form={@form} />`.
  """
  use AppWeb, :html
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
    render: [unsafe: true],
    syntax_highlight: [
      engine: :lumis,
      opts: [formatter: {:html_inline, theme: "github_light"}]
    ]
  ]

  def render(markdown, assigns) do
    case MDEx.to_html(markdown, @mdex_options) do
      {:ok, html} ->
        rendered =
          Phoenix.LiveView.TagEngine.compile(html,
            file: __ENV__.file,
            line: __ENV__.line + 1,
            caller: __ENV__,
            indentation: 0,
            tag_handler: Phoenix.LiveView.HTMLEngine
          )

        {rendered, _} =
          Code.eval_quoted(rendered, [assigns: assigns], Macro.Env.prune_compile_info(__ENV__))

        rendered

      {:error, error} ->
        raise error
    end
  end
end
