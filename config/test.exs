use Mix.Config

config :logger, level: :info

config :active_storage, ecto_repos: [ActiveStorage.Test.Repo]

config :active_storage, :default_source, :amazon

config :active_storage, repo: ActiveStorage.Test.Repo

config :active_storage, secret_key_base: "xxxxxxxxxxx"

config :active_storage, ActiveStorage.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "active_storage_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: 5433,
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 300_000_000,
  timeout: 300_000_000
