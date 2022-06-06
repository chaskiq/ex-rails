defmodule Rails.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  defp aliases do
    [
      "setup.activejob": [
        "cmd --app active_job mix deps.get",
        "cmd --app active_job mix ecto.create",
        "cmd --app active_job mix ecto.migrate"
      ],
      "setup.activestorage": [
        "cmd --app active_storage mix deps.get",
        "cmd --app active_storage mix ecto.create",
        "cmd --app active_storage mix ecto.migrate"
      ],
      "test.activestorage": ["cmd --app active_storage mix test --color"],
      "test.activejob": ["cmd --app active_job mix test --color"],
      # , "test_activestorage"]
      "test.all": [
        "setup.activejob",
        "test.activejob",
        "setup.activestorage",
        "test.activestorage"
      ]
      # test: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      # "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # "ecto.reset": ["ecto.drop", "ecto.setup"],
      # test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      # "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
