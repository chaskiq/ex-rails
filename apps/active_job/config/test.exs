use Mix.Config

config :logger, level: :info

config :active_job, ecto_repos: [ActiveJob.Test.Repo]

config :active_job, repo: ActiveJob.Test.Repo

config :active_job, secret_key_base: "xxxxxxxxxxx"

config :active_job, ActiveJob.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "active_job_test#{System.get_env("MIX_TEST_PARTITION")}",
  port: 5433,
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 300_000_000,
  timeout: 300_000_000

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  # password: "optional_redis_auth",
  namespace: "exq",
  concurrency: :infinite,
  queues: ["default"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 25,
  mode: :default,
  shutdown_timeout: 5000

# config/config.exs
# config :active_job, Oban,
#  repo: ActiveJob.Repo,
#  plugins: [Oban.Plugins.Pruner],
#  queues: [default: 10, events: 50, media: 20]

# confg/test.exs
config :active_job, Oban, testing: :inline, repo: ActiveJob.Test.Repo
