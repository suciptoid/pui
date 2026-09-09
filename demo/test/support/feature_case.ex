defmodule AppWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      # Wallaby's default Chrome capabilities already set a 1280x800 viewport;
      # resizing after session creation makes Chromium CI sessions invalid.

      @endpoint AppWeb.Endpoint

      import Wallaby.Query
    end
  end
end
