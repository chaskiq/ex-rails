defmodule ActiveStorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :active_storage,
      version: "0.0.1",
      elixir: ">= 1.12.0",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description() do
    "A library which allows for file storage compatible with Ruby's activestorage gem"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "active_storage",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chaskiq/active_storage_ex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ActiveStorage.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:ecto, "~> 3.7.2"},
      {:ecto_sql, "~> 3.7.2"},
      {:ex_aws_s3, "~> 2.3"},
      {:ex_aws, "~> 2.2"},
      {:hackney, "~> 1.18"},
      {:sweet_xml, "~> 0.6"},
      # {:mogrify, "~> 0.9.1"},
      {:ex_marcel, git: "https://github.com/chaskiq/ex-marcel.git", branch: "main"},
      {:mogrify, git: "https://github.com/chaskiq/mogrify.git", branch: "identify-option"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug_crypto, "~> 1.0"},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:httpoison, "~> 1.8", only: [:test]},
      {:secure_random, "0.5.1"},
      {:temp, "~> 0.4"},
      {:content_disposition, "1.0.0"},
      {:telemetry, "~> 1.0"},
      {:telemetry_metrics, "~> 0.6.1"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
