defmodule AppWeb.DocsMarkdownTest do
  use ExUnit.Case, async: true

  test "continues parsing markdown after an inline demo component" do
    doc = App.Docs.get_doc!("flash")

    rendered =
      App.Docs.Doc.render(doc.body, %{
        flash: %{},
        flash_position: "top-center",
        flash_stacked: true,
        ping_state: :idle,
        toast_count: 0
      })

    static = IO.iodata_to_binary(rendered.static)

    assert static =~ ~s(id="stacking")
    assert static =~ ~s(id="api-reference")
    assert static =~ "<table"
    refute static =~ "## Stacking"
    refute static =~ "## API Reference"
  end
end
