defmodule ExActiveStorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_active_storage,
      version: "0.1.0",
      elixir: ">= 1.12.0",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:ecto, "~> 3.6.2"},
      {:ecto_sql, "~> 3.6"},
      {:ex_aws_s3, "~> 2.1"},
      {:ex_aws, "~> 2.1"},
      {:mogrify, "~> 0.9.1"},

      {:postgrex, ">= 0.0.0", only: [:test]},
      {:httpoison, "~> 1.8", only: [:test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
