defmodule ActiveJob.Test.Repo do
  use Ecto.Repo,
    otp_app: :active_job,
    adapter: Ecto.Adapters.Postgres
end
