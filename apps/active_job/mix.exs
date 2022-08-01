defmodule ActiveJob.MixProject do
  use Mix.Project

  def project do
    [
      app: :active_job,
      version: "0.1.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      summary: "Job framework with pluggable queues.",
      description: description(),
      package: package()
    ]
  end

  defp description() do
    "Declare job workers that can be run by a variety of queuing backends. This plugin is a port of the Rails ActiveJob gem"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "active_job",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chaskiq/ex-rails/active_job"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger, :exq],
      extra_applications: [:logger],
      mod: {ActiveJob.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/jobs"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oban, "~> 2.12", optional: true},
      # {:ecto, "~> 3.7.2"},
      {:ecto_sql, "~> 3.7"},
      {:exq, "~> 0.16.2", optional: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
