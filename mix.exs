defmodule Blame.MixProject do
  use Mix.Project

  def project do
    [
      app: :ifix_blame,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ash, "~> 2.0.0-rc.0"}
    ]
  end
end
