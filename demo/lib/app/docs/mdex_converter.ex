defmodule App.Docs.MDExConverter do
  @moduledoc """
  Custom HTML converter for NimblePublisher using MDEx.

  Converts markdown to HTML with syntax highlighting and header IDs.
  """

  def convert(_filepath, body, _attrs, _opts) do
    body
    |> MDEx.to_html!(
      extension: [
        strikethrough: true,
        table: true,
        autolink: true,
        tasklist: true,
        header_ids: ""
      ],
      render: [
        # Safe: content comes only from trusted priv/docs/*.md at compile time
        unsafe_: true
      ]
    )
  end
end
