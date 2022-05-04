# frozen_string_literal: true

# require "helper"
# require "jobs/hello_job"
# require "jobs/enqueue_error_job"
# require "active_support/core_ext/numeric/time"

defmodule QueuingTest do
  use ExUnit.Case
  doctest ActiveJob

  import ActiveJob

  setup do
    registry = start_supervised!(JobBuffer)
    Process.register(registry, :job_buffer)
    %{registry: registry}
  end

  test "run queued job" do
    ActiveJob.HelloJob.perform_later(nil)
    assert "David says hello" == JobBuffer.last_value(:job_buffer)
  end

  test "run queued job with arguments" do
    ActiveJob.HelloJob.perform_later "Jamie"
    assert "Jamie says hello" == JobBuffer.last_value(:job_buffer)
  end

  test "run queued job later" do
    # result = HelloJob.set(wait_until: 1.second.ago).perform_later "Jamie"
    # assert result
    # rescue NotImplementedError
    # skip
  end

  test "job returned by enqueue has the arguments available" do
    job = ActiveJob.HelloJob.perform_later "Jamie"
    assert "Jamie" == job.arguments
    # assert_equal [ "Jamie" ], job.arguments
  end

  test "job returned by perform_at has the timestamp available" do
    job = ActiveJob.HelloJob.set(%{wait_until: Date.new!(2014, 1, 1) })
    # assert job.scheduled_at == Date.new!(2014, 1, 1)
    assert_raise RuntimeError, fn ->
      job.__struct__.perform_later(job)
    end
    # job = HelloJob.set(wait_until: Time.utc(2014, 1, 1)).perform_later
    # assert_equal Time.utc(2014, 1, 1).to_f, job.scheduled_at
    # rescue NotImplementedError
    #  skip
  end

  test "job is yielded to block after enqueue with successfully_enqueued property set" do
    ActiveJob.HelloJob.perform_later("John", fn job ->
      assert "John says hello" == JobBuffer.last_value(:job_buffer)
      assert "John" == job.arguments
      assert true == job.__struct__.successfully_enqueued?(job)
      assert nil == job.enqueue_error
    end)
    # HelloJob.perform_later "John" do |job|
    #   assert_equal "John says hello", JobBuffer.last_value
    #   assert_equal [ "John" ], job.arguments
    #   assert_equal true, job.successfully_enqueued?
    #   assert_nil job.enqueue_error
    # end
  end

  test "when enqueuing raises an EnqueueError job is yielded to block with error set on job" do
    ActiveJob.EnqueueErrorJob.perform_later(nil, fn job ->
      assert false == job.__struct__.successfully_enqueued?(job)
      assert nil != job.enqueue_error
      assert job.enqueue_error.__struct__ == ActiveJob.EnqueueError
    end)
    # EnqueueErrorJob.perform_later do |job|
    #  assert_equal false, job.successfully_enqueued?
    #  assert_equal ActiveJob::EnqueueError, job.enqueue_error.class
    # end
  end
end
