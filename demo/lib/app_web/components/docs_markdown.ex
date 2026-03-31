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

  def render(markdown, assigns) do
    MDEx.to_heex!(markdown,
      assigns: assigns,
      extension: [
        strikethrough: true,
        table: true,
        autolink: true,
        tasklist: true,
        header_ids: ""
      ]
    )
  end
end
