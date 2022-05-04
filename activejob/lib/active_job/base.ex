defmodule ActiveJob.Base do
  # = Active Job
  #
  # Active Job objects can be configured to work with different backend
  # queuing frameworks. To specify a queue adapter to use:
  #
  #   ActiveJob::Base.queue_adapter = :inline
  #
  # A list of supported adapters can be found in QueueAdapters.
  #
  # Active Job objects can be defined by creating a class that inherits
  # from the ActiveJob::Base class. The only necessary method to
  # implement is the "perform" method.
  #
  # To define an Active Job object:
  #
  #   class ProcessPhotoJob < ActiveJob::Base
  #     def perform(photo)
  #       photo.watermark!('Rails')
  #       photo.rotate!(90.degrees)
  #       photo.resize_to_fit!(300, 300)
  #       photo.upload!
  #     end
  #   end
  #
  # Records that are passed in are serialized/deserialized using Global
  # ID. More information can be found in Arguments.
  #
  # To enqueue a job to be performed as soon as the queuing system is free:
  #
  #   ProcessPhotoJob.perform_later(photo)
  #
  # To enqueue a job to be processed at some point in the future:
  #
  #   ProcessPhotoJob.set(wait_until: Date.tomorrow.noon).perform_later(photo)
  #
  # More information can be found in ActiveJob::Core::ClassMethods#set
  #
  # A job can also be processed immediately without sending to the queue:
  #
  #  ProcessPhotoJob.perform_now(photo)
  #
  # == Exceptions
  #
  # * DeserializationError - Error class for deserialization errors.
  # * SerializationError - Error class for serialization errors.

  # include Core
  # include QueueAdapter
  # include QueueName
  # include QueuePriority
  # include Enqueuing
  # include Execution
  # include Callbacks
  # include Exceptions
  # include Instrumentation
  # include Logging
  # include Timezones
  # include Translation

  # ActiveSupport.run_load_hooks(:active_job, self)

  defmacro __using__(opts) do
    IO.inspect("job opts:")
    IO.inspect(opts)

    queue_adapter = Keyword.get(opts, :queue_adapter)
    callbacks = Keyword.get(opts, :callbacks)

    quote do
      # Core functions
      use ActiveJob.Core, callbacks: unquote(callbacks)
      # defdelegate new(arguments), to: ActiveJob.Core
      # defdelegate successfully_enqueued?(struct), to: ActiveJob.Core
      # defdelegate deserialize(struct, job_data), to: ActiveJob.Core
      # defdelegate set(struct, options), to: ActiveJob.Core
      # defdelegate serialize_arguments_if_needed(struct, arguments), to: ActiveJob.Core
      # defdelegate deserialize_arguments_if_needed(struct), to: ActiveJob.Core
      # defdelegate serialize_arguments(arguments), to: ActiveJob.Core
      # defdelegate deserialize_arguments(serialized_args), to: ActiveJob.Core
      # defdelegate arguments_serialized?(struct), to: ActiveJob.Core

      # Queue Adapter
      use ActiveJob.QueueAdapter, queue_adapter: unquote(queue_adapter)
      # defdelegate queue_adapter(), to: ActiveJob.QueueAdapter
      # defdelegate queue_adapter_name(), to: ActiveJob.QueueAdapter
      # defdelegate set_queue_adapter(name_or_adapter), to: ActiveJob.QueueAdapter
      # defdelegate assign_adapter(queue_adapter), to: ActiveJob.QueueAdapter
      # defdelegate queue_adapter?(object), to: ActiveJob.QueueAdapter

      # QueueName
      use ActiveJob.Enqueuing
      # defdelegate perform_later(args, block \\ nil), to: ActiveJob.Enqueuing
      # defdelegate job_or_instantiate(args), to: ActiveJob.Enqueuing
      # defdelegate enqueue(struct, options \\ %{}), to: ActiveJob.Enqueuing

      # Execution
      use ActiveJob.Execution
      # defdelegate perform_now(args), to: ActiveJob.Execution
      # defdelegate execute(job_data), to: ActiveJob.Execution
      # defdelegate perform_now(struct), to: ActiveJob.Execution
      # defdelegate perform(struct, any), to: ActiveJob.Execution
      # defdelegate _perform_job(struct), to: ActiveJob.Execution

      # Callbacks

      # Priority
    end
  end
end
