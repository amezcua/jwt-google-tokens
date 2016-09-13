defmodule Jwt.Mixfile do
  use Mix.Project

  def project do
    [app: :jwt,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [ applications: [:logger, :httpoison, :cowboy, :plug] ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
    {:httpoison, "~> 0.9.0" },
    {:poison, "~> 2.0" },
    {:ex_doc, github: "elixir-lang/ex_doc" },
    {:cowboy, "~> 1.0.0"},
    {:plug, "~> 1.0"}
    ]
  end
end
