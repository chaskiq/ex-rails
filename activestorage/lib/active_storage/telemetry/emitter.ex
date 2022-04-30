defmodule ActiveStorage.Metrics do
  # Metrics.Telemetry.start_link(%{})
  # :telemetry.execute([key, :emit], %{value: value})

  def instrument(key, args, block) do
    res = block.()
    :telemetry.execute([key, :emit], %{system_time: System.system_time()}, args)
    res
  end
end
