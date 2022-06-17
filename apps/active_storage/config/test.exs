use Mix.Config

config :logger, level: :info

config :active_storage, ecto_repos: [ActiveStorage.Test.Repo]

config :active_storage, :service, :local

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

config :active_storage, :services,
  amazon: [
    service: "S3",
    bucket: "active-storage-test",
    access_key_id: "root",
    secret_access_key: "active_storage_test",
    scheme: "http://",
    host: "localhost",
    port: 9000,
    force_path_style: true
  ],
  minio: [
    service: "S3",
    bucket: "active-storage-test",
    access_key_id: "root",
    secret_access_key: "active_storage_test",
    scheme: "http://",
    host: "localhost",
    port: 9000,
    force_path_style: true
  ],
  local: [service: "Disk", root: Path.join(File.cwd!(), "tmp/storage")],
  local_public: [service: "Disk", root: Path.join(File.cwd!(), "tmp/storage"), public: true],
  test: [
    service: "Disk",
    root: "tmp/storage"
  ]

# "local" => { "service" => "Disk", "root" => Dir.mktmpdir("active_storage_tests") },
# "local_public" => { "service" => "Disk", "root" => Dir.mktmpdir("active_storage_tests"), "public" => true },
# "disk_mirror_1" => { "service" => "Disk", "root" => Dir.mktmpdir("active_storage_tests_1") },
# "disk_mirror_2" => { "service" => "Disk", "root" => Dir.mktmpdir("active_storage_tests_2") },
# "disk_mirror_3" => { "service" => "Disk", "root" => Dir.mktmpdir("active_storage_tests_3") },
# "mirror" => { "service" => "Mirror", "primary" => "local", "mirrors" => ["disk_mirror_1", "disk_mirror_2", "disk_mirror_3"] }
