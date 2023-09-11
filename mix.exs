defmodule Commoner.MixProject do
  use Mix.Project

  def project do
    [
      app: :commoner,
      version: "0.1.0",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:common_test]
    ]
  end


  defp deps do
    [
    ]
  end
end
