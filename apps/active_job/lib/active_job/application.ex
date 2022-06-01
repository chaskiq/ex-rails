defmodule ActiveJob.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        ActiveJob.Test.Repo,
        obanapp()
        # {Oban, oban_config()}
        # Exq,
        # Starts a worker by calling: ActiveJob.Worker.start_link(arg)
        # {ActiveJob.Worker, arg}
      ]
      |> Enum.filter(fn x -> x end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ActiveJob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp obanapp do
    if Code.ensure_loaded?(Oban) do
      Application.ensure_all_started(:oban)
      {Oban, Application.fetch_env!(:active_job, Oban)}
    end
  end
end
