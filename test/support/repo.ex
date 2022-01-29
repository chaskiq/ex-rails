defmodule ActiveStorage.Test.Repo do
  use Ecto.Repo,
    otp_app: :ex_active_storage,
    adapter: Ecto.Adapters.Postgres
end
