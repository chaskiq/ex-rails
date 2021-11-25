use Mix.Config

config :logger, level: :info

config :ExActiveStorage, ecto_repos: [ExActiveStorage.Repo]

config :ExActiveStorage, repo: ExActiveStorage.Repo

config :ExActiveStorage, ExActiveStorage.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_active_storage_test",
  hostname: "db",
  poolsize: 10
