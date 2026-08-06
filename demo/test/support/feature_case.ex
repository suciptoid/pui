defmodule AppWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      @sessions [[window_size: [width: 1280, height: 800]]]

      @endpoint AppWeb.Endpoint

      import Wallaby.Query
    end
  end
end
