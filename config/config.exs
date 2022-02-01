# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :taglet, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:taglet, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# Use rails credentials:edit to set the AWS secrets (as aws:access_key_id|secret_access_key)
config :active_storage, :services,
  amazon: %{
    service: "S3",
    bucket: "active-storage-test",
    access_key_id: "root",
    secret_access_key: "active_storage_test",
    scheme: "http://",
    host: "localhost",
    port: 9000,
    force_path_style: true
  },
  minio: %{
    service: "S3",
    bucket: "active-storage-test",
    access_key_id: "root",
    secret_access_key: "active_storage_test",
    scheme: "http://",
    host: "localhost",
    port: 9000,
    force_path_style: true
  },
  local: %{service: "Disk", root: "storage"},
  test: %{
    service: "Disk",
    root: "tmp/storage"
  }

# Configure mogrify command:

config :mogrify,
  mogrify_command: [
    path: "magick",
    args: ["mogrify"]
  ]

# Configure convert command:

config :mogrify,
  convert_command: [
    path: "magick",
    args: ["convert"]
  ]

# Configure identify command:

config :mogrify,
  identify_command: [
    path: "magick",
    args: ["identify"]
  ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
