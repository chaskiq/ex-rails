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

  defmacro __using__(opts) do
    # IO.inspect("job opts:")
    # IO.inspect(opts)

    queue_adapter = Keyword.get(opts, :queue_adapter)
    callbacks = Keyword.get(opts, :callbacks)

    quote do
      # Core functions
      use ActiveJob.Core, callbacks: unquote(callbacks)
      # Queue Adapter
      use ActiveJob.QueueAdapter, queue_adapter: unquote(queue_adapter)
      # Enqueuing
      use ActiveJob.Enqueuing
      # Execution
      use ActiveJob.Execution
      # Callbacks
      # Priority
      # QueueAdapter
      # QueueName
      # QueuePriority
      # Callbacks
      # Exceptions
      # Instrumentation
      # Logging
      # Timezones
      # Translation
    end
  end
end
