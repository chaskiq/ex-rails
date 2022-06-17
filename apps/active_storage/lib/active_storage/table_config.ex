defmodule ActiveStorage.TableConfig do
  use GenServer

  def init(arg) do
    :ets.new(:active_storage_config, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])

    setup()

    {:ok, arg}
  end

  def setup() do
    ActiveStorage.TableConfig.put("track_variants", true)

    configs = Application.get_env(:active_storage, :services)
    ActiveStorage.TableConfig.put("services", ActiveStorage.Service.Registry.new(configs))

    if config_choice = Application.get_env(:active_storage, :service) do
      ActiveStorage.TableConfig.put(
        "service",
        ActiveStorage.Blob.services().__struct__.fetch(config_choice)
      )

      # ActiveStorage.Blob.services().fetch(config_choice)
      # ActiveStorage.TableConfig.put("services", ActiveStorage.Service.Registry.new(configs))
    end

    # ActiveStorage::Blob.services = ActiveStorage.Service.Registry.new(configs)
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def get(key) do
    case :ets.lookup(:active_storage_config, key) do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def put(key, value) do
    :ets.insert(:active_storage_config, {key, value})
  end
end
