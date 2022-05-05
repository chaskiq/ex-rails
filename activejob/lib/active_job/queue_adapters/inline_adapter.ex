defmodule ActiveJob.QueueAdapters.InlineAdapter do
  # == Active Job Inline adapter
  #
  # When enqueuing jobs with the Inline adapter the job will be executed
  # immediately.
  #
  # To use the Inline set the queue_adapter config to +:inline+.
  #
  #   Rails.application.config.active_job.queue_adapter = :inline
  defstruct [:mod]

  def new do
    %__MODULE__{
      mod: __MODULE__
    }
  end

  def enqueue(job, options) do
    IO.inspect("ENQUEUE FROM INLINE ADAPTER!")
    job.__struct__.execute(job, options)
    # Base.execute(job.serialize)
  end

  def enqueue_at(job, options) do
    raise ActiveJob.NotImplementedError,
      message:
        "Not implemented: Use a queueing backend to enqueue jobs in the future. Read more at https://guides.rubyonrails.org/active_job_basics.html"
  end
end
