defmodule PUI do
  @moduledoc """
  PUI keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro __using__(_opts) do
    quote do
      import PUI
      import PUI.Input
      import PUI.Button
      import PUI.Accordion
      import PUI.Dropdown
      import PUI.Alert
      import PUI.Popover
      import PUI.Select
      import PUI.Tabs
      import PUI.Dialog
      import PUI.Components
    end
  end

  defdelegate popover_base(assigns), to: PUI.Popover, as: :base
end
