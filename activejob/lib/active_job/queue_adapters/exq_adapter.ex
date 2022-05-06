# {:ok, ack} = Exq.enqueue(Exq, "default", MyWorker, ["arg1", "arg2"])

# {:ok, ack} = Exq.enqueue(Exq, "default", "MyWorker", ["arg1", "arg2"])

## Don't retry job in per worker
# {:ok, ack} = Exq.enqueue(Exq, "default", MyWorker, ["arg1", "arg2"], max_retries: 0)
## max_retries = 10, it will override :max_retries in config
# {:ok, ack} = Exq.enqueue(Exq, "default", MyWorker, ["arg1", "arg2"], max_retries: 10)

defmodule ActiveJob.QueueAdapters.ExqAdapter do
  # == Active Job Exq adapter

  defstruct [:mod]

  def new do
    %__MODULE__{
      mod: __MODULE__
    }
  end

  def enqueue(job, options \\ []) do
    queue_name = job.queue_name || :default
    wait = Map.get(options, :wait)

    IO.inspect("ENQUEUE FROM Exq ADAPTER with QUEUE: #{queue_name}")

    case wait do
      nil ->
        {:ok, ack} =
          Exq.enqueue(
            Exq,
            queue_name,
            ActiveJob.QueueAdapters.ExqAdapter.JobWrapper,
            [job.__struct__.serialize(job)]
          )

      time ->
        Exq.enqueue_at(
          Exq,
          "default",
          time,
          ActiveJob.QueueAdapters.ExqAdapter.JobWrapper,
          [job.__struct__.serialize(job)]
        )
    end
  end
end

defmodule ActiveJob.QueueAdapters.ExqAdapter.JobWrapper do
  def perform(args) do
    IO.inspect("ExQ WRAPPER HERE!")
    mod = Module.concat([args["job_class"]])
    job = mod.deserialize(struct(mod), args)
    mod.execute(job, job)
    :ok
  end
end
