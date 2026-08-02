defmodule PUI.TestIconProvider do
  use Phoenix.Component

  @behaviour PUI.IconProvider

  @impl true
  def render(token, assigns) do
    assigns = assign(assigns, :token, token)

    ~H"""
    <i data-test-icon={@token} class={@class} {@rest}></i>
    """
  end
end
