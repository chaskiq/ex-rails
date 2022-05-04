# frozen_string_literal: true

# require "active_job/arguments"

defmodule ActiveJob.Enqueuing do
  defmacro __using__(_opts) do
    quote do
      # Provides behavior for enqueuing jobs.

      # Can be raised by adapters if they wish to communicate to the caller a reason
      # why the adapter was unexpectedly unable to enqueue a job.

      # Includes the +perform_later+ method for job initialization.

      # Push a job onto the queue. By default the arguments must be either String,
      # Integer, Float, NilClass, TrueClass, FalseClass, BigDecimal, Symbol, Date,
      # Time, DateTime, ActiveSupport::TimeWithZone, ActiveSupport::Duration,
      # Hash, ActiveSupport::HashWithIndifferentAccess, Array, Range, or
      # GlobalID::Identification instances, although this can be extended by adding
      # custom serializers.
      #
      # Returns an instance of the job class queued with arguments available in
      # Job#arguments or false if the enqueue did not succeed.
      #
      # After the attempted enqueue, the job will be yielded to an optional block.

      def perform_later(args, block \\ nil) do
        job = job_or_instantiate(args)
        job = job.__struct__.enqueue(job)

        if block do
          block.(job)
          # yield job if block_given?
        else
          job
        end
      end

      def job_or_instantiate(nil) do
        __MODULE__.new(nil)
      end

      def job_or_instantiate(args) do
        case args do
          %__MODULE__{} = struct -> struct
          _ -> __MODULE__.new(args)
        end

        # args.first.is_a?(self) ? args.first : new(*args)
      end

      # ruby2_keywords(:job_or_instantiate)

      # Enqueues the job to be performed by the queue adapter.
      #
      # ==== Options
      # * <tt>:wait</tt> - Enqueues the job with the specified delay
      # * <tt>:wait_until</tt> - Enqueues the job at the time specified
      # * <tt>:queue</tt> - Enqueues the job on the specified queue
      # * <tt>:priority</tt> - Enqueues the job with the specified priority
      #
      # ==== Examples
      #
      #    my_job_instance.enqueue
      #    my_job_instance.enqueue wait: 5.minutes
      #    my_job_instance.enqueue queue: :important
      #    my_job_instance.enqueue wait_until: Date.tomorrow.midnight
      #    my_job_instance.enqueue priority: 10
      def enqueue(struct, options \\ %{}) do
        struct = set(struct, options)
        module = struct.__struct__
        struct = struct |> Map.merge(%{successfully_enqueued: false})

        # module.run_callbacks struct, :enqueue do
        struct =
          try do
            if struct.scheduled_at do
              IO.puts("SCHEDULE FROM QUEUE ADAPTER (scheduled_at)")
              IO.inspect(module.queue_adapter)
              module.queue_adapter.enqueue_at(struct, struct.scheduled_at)
              # queue_adapter.enqueue_at self, scheduled_at
            else
              IO.puts("SCHEDULE FROM QUEUE ADAPTER")
              IO.inspect(module.queue_adapter)
              module.queue_adapter.enqueue(struct, options)
              # queue_adapter.enqueue self
            end

            struct |> Map.merge(%{successfully_enqueued: true})
          rescue
            e ->
              IO.inspect(e)
              IO.inspect(inspect(__STACKTRACE__))
              struct |> Map.merge(%{enqueue_error: e})
          end

        # if module.successfully_enqueued?(struct) do
        #  struct
        # else
        #  false
        # end
        struct
      end
    end
  end
end
