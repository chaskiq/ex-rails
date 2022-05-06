defmodule ActiveJob.QueueAdapters.AsyncAdapter do
  # == Active Job Async adapter
  #
  # The Async adapter runs jobs with an in-process thread pool.
  #
  # This is the default queue adapter. It's well-suited for dev/test since
  # it doesn't need an external infrastructure, but it's a poor fit for
  # production since it drops pending jobs on restart.
  #
  # To use this adapter, set queue adapter to +:async+:
  #
  #   config.active_job.queue_adapter = :async
  #
  # To configure the adapter's thread pool, instantiate the adapter and
  # pass your own config:
  #
  #   config.active_job.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new \
  #     min_threads: 1,
  #     max_threads: 2 * Concurrent.processor_count,
  #     idletime: 600.seconds
  #
  # The adapter uses a {Concurrent Ruby}[https://github.com/ruby-concurrency/concurrent-ruby] thread pool to schedule and execute
  # jobs. Since jobs share a single thread pool, long-running jobs will block
  # short-lived jobs. Fine for dev/test; bad for production.

  defstruct [:mod, :scheduler]

  def new do
    # find or register the gen server
    %__MODULE__{
      mod: __MODULE__,
      scheduler: find_pid()
    }
  end

  def find_pid() do
    case Process.whereis(ActiveJob.QueueAdapters.AsyncAdapter.Scheduler) do
      nil ->
        {:ok, pid} = ActiveJob.QueueAdapters.AsyncAdapter.Scheduler.new()
        Process.register(pid, ActiveJob.QueueAdapters.AsyncAdapter.Scheduler)
        pid

      pid ->
        pid
    end
  end

  # See {Concurrent::ThreadPoolExecutor}[https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/ThreadPoolExecutor.html] for executor options.
  # def new(executor_options) do
  #  # @scheduler = Scheduler.new(**executor_options)
  # end

  def enqueue(job, a) do
    pid = job.__struct__.queue_adapter.scheduler
    ActiveJob.QueueAdapters.AsyncAdapter.Scheduler.enqueue(pid, job)
    # @scheduler.enqueue JobWrapper.new(job), queue_name: job.queue_name
  end

  def enqueue_at(job, timestamp) do
    pid = job.__struct__.queue_adapter.scheduler
    ActiveJob.QueueAdapters.AsyncAdapter.Scheduler.enqueue_at(pid, job)
    # @scheduler.enqueue_at JobWrapper.new(job), timestamp, queue_name: job.queue_name
  end

  # Gracefully stop processing jobs. Finishes in-progress work and handles
  # any new jobs following the executor's fallback policy (`caller_runs`).
  # Waits for termination by default. Pass `wait: false` to continue.
  def shutdown(opts \\ []) do
    opts = Keyword.merge([wait: true], opts)
    #  @scheduler.shutdown wait: wait
  end

  # Used for our test suite.
  # def immediate=(immediate) do
  # @scheduler.immediate = immediate
  # end
end

# Note that we don't actually need to serialize the jobs since we're
# performing them in-process, but we do so anyway for parity with other
# adapters and deployment environments. Otherwise, serialization bugs
# may creep in undetected.
defmodule ActiveJob.QueueAdapters.AsyncAdapter.JobWrapper do
  defstruct [:job]

  def new(job) do
    # job.provider_job_id = SecureRandom.uuid
    # @job_data = job.serialize
    %__MODULE__{
      job: job
    }
  end

  def perform(job) do
    job.__struct__.execute(job, %{})
    # Base.execute @job_data
  end
end

defmodule ActiveJob.QueueAdapters.AsyncAdapter.Scheduler do
  # DEFAULT_EXECUTOR_OPTIONS = {
  #   min_threads:     0,
  #   max_threads:     Concurrent.processor_count,
  #   auto_terminate:  true,
  #   idletime:        60, # 1 minute
  #   max_queue:       0, # unlimited
  #   fallback_policy: :caller_runs # shouldn't matter -- 0 max queue
  # }.freeze

  # attr_accessor :immediate

  use GenServer

  def new() do
    __MODULE__.start_link([])
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [])
    # GenServer.start_link(__MODULE__, [], name: :"__MODULE__:1")
    # GenServer.start_link(__MODULE__, [], name: {:via, Registry, {:async_adapter, table}})
  end

  def schedule, do: Process.send_after(self(), :work, 2000)

  def handle_info(:work, [job | state]) do
    job_wrapper = ActiveJob.QueueAdapters.AsyncAdapter.JobWrapper.new(job)

    case job_wrapper.__struct__.perform(job) do
      %{enqueue_error: err} = job ->
        schedule()
        {:noreply, [state] ++ job}

      _ ->
        schedule()
        {:noreply, state}
    end
  end

  def handle_info(:work, []) do
    IO.inspect("NO MORE JOBS")
    schedule()
    {:noreply, []}
  end

  def init(args) do
    schedule()
    {:ok, []}
    # self.immediate = false
    # @immediate_executor = Concurrent::ImmediateExecutor.new
    # @async_executor = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS.merge(options))
  end

  def enqueue(pid, job) do
    # executor.post(job, &:perform)
    GenServer.cast(pid, {:push, job})
  end

  def enqueue_at(pid, job, timestamp, opts \\ []) do
    defaults =
      if timestamp > 0 do
        spawn(fn ->
          :timer.sleep(1000)
          enqueue(pid, job)
        end)
      else
        # , queue_name: "foo")
        enqueue(pid, job)
      end

    # delay = timestamp - Time.current.to_f
    # if delay > 0
    #  Concurrent::ScheduledTask.execute(delay, args: [job], executor: executor, &:perform)
    # else
    #  enqueue(job, queue_name: queue_name)
    # end
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def handle_call(:pop, _from, [item | rest]) do
    {:reply, item, rest}
  end

  def handle_cast({:push, item}, stack) do
    {:noreply, [item | stack]}
  end

  def values(pid) do
    GenServer.call(pid, :list)
  end

  def last_value(pid) do
    GenServer.call(pid, :last_value)
  end

  def handle_call(:size, _from, stack) do
    {:reply, Enum.count(stack), stack}
  end

  def handle_call(:list, _from, stack) do
    {:reply, stack, stack}
  end

  def shutdown(opts \\ []) do
    opts = Keyword.merge([wait: true], opts)
    # @async_executor.shutdown
    # @async_executor.wait_for_termination if wait
  end

  def executor do
    # immediate ? @immediate_executor : @async_executor
  end
end
