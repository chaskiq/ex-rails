use Mix.Config

config :logger, level: :info

config :ex_active_storage, ecto_repos: [ExActiveStorage.Repo]

config :ex_active_storage, repo: ExActiveStorage.Repo

config :ex_active_storage, ExActiveStorage.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_active_storage_test",
  port: 5433,
  hostname: "localhost",
  poolsize: 10
