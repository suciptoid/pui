defmodule AppWeb.PageNotFoundError do
  @moduledoc """
  Raised when a demo or docs page slug does not match any known page.

  The `plug_status` renders the standard 404 error page instead of
  silently falling back to another page.
  """

  defexception message: "Page not found", plug_status: 404
end
