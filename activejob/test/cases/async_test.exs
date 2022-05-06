defmodule AsyncTest do
  use ExUnit.Case
  doctest ActiveJob

  alias ActiveJob

  setup do
    registry = start_supervised!(JobBuffer)
    Process.register(registry, :job_buffer)
    %{registry: registry}
  end

  test "run queued job with arguments" do
    ActiveJob.AsyncJob.perform_later("Jamie")
    assert "Jamie says hello" == JobBuffer.last_value(:job_buffer)
  end
end