defmodule ActiveJob.QueueAdapters.ObanAdapter do
  # == Active Job Oban adapter
  #
  #

  defstruct [:mod]

  def new do
    %__MODULE__{
      mod: __MODULE__
    }
  end

  def enqueue(job, options) do
    queue_name = job.queue_name || :default

    IO.inspect("ENQUEUE FROM OBAN ADAPTER with QUEUE: #{queue_name}")

    job.__struct__.serialize(job)
    |> Oban.Job.new(
      queue: queue_name,
      worker: ActiveJob.QueueAdapters.ObanAdapter.JobWrapper
    )
    |> Oban.insert()
  end

  def enqueue_at(job, options) do
    raise "Not implemented: Use a queueing backend to enqueue jobs in the future. Read more at https://guides.rubyonrails.org/active_job_basics.html"
  end
end

defmodule ActiveJob.QueueAdapters.ObanAdapter.JobWrapper do
  # , queue: :events
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args} = oban_job) do
    IO.inspect("OBAN WRAPPER HERE!")
    mod = Module.concat([args["job_class"]])
    job = mod.deserialize(struct(mod), args)
    mod.execute(job, job)
    :ok
  end
end
