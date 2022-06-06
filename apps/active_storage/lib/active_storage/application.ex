defmodule ActiveStorage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExMarcel.TableWrapper,
      ActiveStorage.TableConfig
      # Starts a worker by calling: ActiveStorage.Worker.start_link(arg)
      # {ActiveStorage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ActiveStorage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
