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
  database: "active_storage_test",
  port: 5433,
  hostname: "localhost",
  poolsize: 10

config :ex_aws, :s3,
  scheme: "http://",
  # <- not sure what is the minio endpoint
  host: "s3.amazonaws.com",
  region: "us-east-1"

config :active_storage, :storage,
  amazon: %{
    service: "S3",
    region: System.get_env("AWS_S3_REGION"),
    access_key_id: "abcd1234",
    secret_access_key: "efgh5678",
    bucket: System.get_env("AWS_BUCKET")
  },
  local: %{service: "Disk", root: "storage"},
  test: %{
    service: "Disk",
    root: "tmp/storage"
  }
