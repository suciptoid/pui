defmodule PUI do
  @moduledoc """
  Public entry point for the PUI Phoenix LiveView UI toolkit.

  `use PUI` imports the primary component families for use in HEEx
  templates. Flash and loading modules remain available through their
  qualified module names.
  """

  defmacro __using__(_opts) do
    quote do
      import PUI
      import PUI.Input
      import PUI.Button
      import PUI.ButtonGroup
      import PUI.Accordion
      import PUI.Dropdown
      import PUI.Alert
      import PUI.Popover
      import PUI.Select
      import PUI.DatePicker
      import PUI.Chart
      import PUI.Tabs
      import PUI.Dialog
      import PUI.Layout
      import PUI.Badge
      import PUI.Progress
      import PUI.Card
      import PUI.Table

      import PUI.Container,
        except: [
          card: 1,
          card_header: 1,
          card_title: 1,
          card_description: 1,
          card_action: 1,
          card_content: 1,
          card_footer: 1
        ]

      import PUI.Components, except: [badge: 1, progress: 1]
    end
  end

  defdelegate popover_base(assigns), to: PUI.Popover, as: :base
end
