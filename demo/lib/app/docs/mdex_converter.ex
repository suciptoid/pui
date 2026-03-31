defmodule App.Docs.MDExConverter do
  @moduledoc """
  Pass-through converter for docs content.

  The docs pages render markdown through `MDEx.to_heex!/2` at request time so
  inline Phoenix components can be embedded directly inside the markdown body.
  """

  def convert(_filepath, body, _attrs, _opts), do: body
end
