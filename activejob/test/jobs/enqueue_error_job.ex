# frozen_string_literal: true

defmodule ActiveJob.EnqueueErrorAdapter do
  def enqueue(job, options) do
    raise ActiveJob.EnqueueError, message: "There was an error enqueuing the job"
  end

  def enqueue_at(job, options) do
    raise ActiveJob.EnqueueError, message: "There was an error enqueuing the job"
  end
end

defmodule ActiveJob.EnqueueErrorJob do
  use ActiveJob.Base,
    queue_adapter: ActiveJob.EnqueueErrorAdapter

  def perform do
    raise "This should never be called"
  end
end
