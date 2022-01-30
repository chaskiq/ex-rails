use Mix.Config

config :logger, level: :info

config :active_storage, ecto_repos: [ActiveStorage.Test.Repo]

config :active_storage, repo: ActiveStorage.Test.Repo

config :active_storage, secret_key_base: "xxxxxxxxxxx"

config :active_storage, ActiveStorage.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "active_storage_test",
  port: 5433,
  hostname: "localhost",
  poolsize: 10
