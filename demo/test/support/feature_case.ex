defmodule AppWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      @endpoint AppWeb.Endpoint

      import Wallaby.Query
    end
  end
end
