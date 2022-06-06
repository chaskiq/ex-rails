defmodule ExqTest do
  use ExUnit.Case
  doctest ActiveJob

  alias ActiveJob.{ExqJob}
  alias ActiveJob.QueueAdapters.ExqAdapter.{JobWrapper}

  setup do
    registry = start_supervised!(JobBuffer)
    Process.register(registry, :job_buffer)
    %{registry: registry}
  end

  test "ex job perform later" do
    ExqJob.perform_later(%{"a"=> "David", "b"=> 2})
    :timer.sleep(2000)

    assert "David says hello 2 times" == JobBuffer.last_value(:job_buffer)
  end

  test "ex job perform now" do
    ExqJob.perform_now(%{"a"=> "David", "b"=> 2})
    assert "David says hello 2 times" == JobBuffer.last_value(:job_buffer)
  end
end
