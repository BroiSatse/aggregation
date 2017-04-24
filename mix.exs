defmodule Aggregation.Mixfile do
  use Mix.Project

  def project do
    [app: :aggregation,
     version: "0.1.0",
     build_path: "_build",
     config_path: "config/config.exs",
     deps_path: "deps",
     lockfile: "mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     consolidate_protocols: Mix.env != :test,
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger],
      mod: {Aggregation, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:pipeline, git: "https://github.com/BroiSatse/ex-pipeline.git"},
      {:extreme, "~> 0.8.1"},
      {:poison, "~> 3.0"},
      {:vex, "~> 0.6.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end
