# frozen_string_literal: true

# require "helper"
# require "jobs/hello_job"
# require "jobs/enqueue_error_job"
# require "active_support/core_ext/numeric/time"

defmodule QueuingTest do
  use ExUnit.Case
  doctest ActiveJob

  alias ActiveJob.{ObanJob}
  alias ActiveJob.QueueAdapters.ObanAdapter.{JobWrapper}

  setup do
    registry = start_supervised!(JobBuffer)
    Process.register(registry, :job_buffer)
    %{registry: registry}
  end

  test "oban job" do
    Oban.Testing.with_testing_mode(:inline, fn ->
      ObanJob.perform_later(%{a: "David", b: 2})
      assert "David says hello 2 times" == JobBuffer.last_value(:job_buffer)
    end)
  end
end
