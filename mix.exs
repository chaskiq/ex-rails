defmodule ExActiveStorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_active_storage,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.6.2"},
      {:ex_aws_s3, "~> 2.1"},
      {:ex_aws, "~> 2.1"},
      {:mogrify, "~> 0.9.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
