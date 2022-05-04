defmodule ActiveJob.Core do
  defmacro __using__(opts) do
    callbacks = Keyword.get(opts, :callbacks)

    quote do
      defstruct [
        :arguments,
        :serialized_arguments,
        # Timestamp when the job should be performed
        :scheduled_at,
        # Job Identifier
        :job_id,
        # Queue in which the job will reside.
        :queue_name,
        # Priority that the job will have (lower is more priority).
        :priority,
        # ID optionally provided by adapter
        :provider_job_id,
        # Number of times this job has been executed (which increments on every retry, like after an exception).
        :executions,
        # Hash that contains the number of times this job handled errors for each specific retry_on declaration.
        # Keys are the string representation of the exceptions listed in the retry_on declaration,
        # while its associated value holds the number of executions where the corresponding retry_on
        # declaration handled one of its listed exceptions.
        :exception_executions,
        # I18n.locale to be used during the job.
        :locale,
        # Timezone to be used during the job.
        :timezone,
        # Track when a job was enqueued
        :enqueued_at,
        # Track whether the adapter received the job successfully.
        :successfully_enqueued,
        # Track any exceptions raised by the backend so callers can inspect the errors.
        :enqueue_error,
        # Set callbacks
        :callbacks
      ]

      # Creates a job preconfigured with the given options. You can call
      # perform_later with the job arguments to enqueue the job with the
      # preconfigured options
      #
      # ==== Options
      # * <tt>:wait</tt> - Enqueues the job with the specified delay
      # * <tt>:wait_until</tt> - Enqueues the job at the time specified
      # * <tt>:queue</tt> - Enqueues the job on the specified queue
      # * <tt>:priority</tt> - Enqueues the job with the specified priority
      #
      # ==== Examples
      #
      #    VideoJob.set(queue: :some_queue).perform_later(Video.last)
      #    VideoJob.set(wait: 5.minutes).perform_later(Video.last)
      #    VideoJob.set(wait_until: Time.now.tomorrow).perform_later(Video.last)
      #    VideoJob.set(queue: :some_queue, wait: 5.minutes).perform_later(Video.last)
      #    VideoJob.set(queue: :some_queue, wait_until: Time.now.tomorrow).perform_later(Video.last)
      #    VideoJob.set(queue: :some_queue, wait: 5.minutes, priority: 10).perform_later(Video.last)
      def set(options) do
        ActiveJob.ConfiguredJob.new(__MODULE__, options)
      end

      def new(arguments \\ nil) do
        %__MODULE__{
          arguments: arguments,
          job_id: Ecto.UUID.bingenerate() |> Ecto.UUID.cast!(),
          # self.class.queue_name
          queue_name: nil,
          # self.class.priority
          priority: nil,
          executions: 0,
          exception_executions: %{},
          # Time.zone&.name
          timezone: :utc,
          callbacks: unquote(callbacks)
        }
      end

      def successfully_enqueued?(struct) do
        struct.successfully_enqueued
      end

      # Attaches the stored job data to the current instance. Receives a hash
      # returned from +serialize+
      #
      # ==== Examples
      #
      #    class DeliverWebhookJob < ActiveJob::Base
      #      attr_writer :attempt_number
      #
      #      def attempt_number
      #        @attempt_number ||= 0
      #      end
      #
      #      def serialize
      #        super.merge('attempt_number' => attempt_number + 1)
      #      end
      #
      #      def deserialize(job_data)
      #        super
      #        self.attempt_number = job_data['attempt_number']
      #      end
      #
      #      rescue_from(Timeout::Error) do |exception|
      #        raise exception if attempt_number > 5
      #        retry_job(wait: 10)
      #      end
      #    end
      def deserialize(struct, job_data) do
        struct
        |> Map.merge(%{
          job_id: job_data["job_id"],
          provider_job_id: job_data["provider_job_id"],
          queue_name: job_data["queue_name"],
          priority: job_data["priority"],
          serialized_arguments: job_data["arguments"],
          executions: job_data["executions"],
          exception_executions: job_data["exception_executions"],
          # || I18n.locale.to_s,
          locale: job_data["locale"],
          # || Time.zone&.name,
          timezone: job_data["timezone"],
          enqueued_at: job_data["enqueued_at"]
        })
      end

      # Configures the job with the given options.
      def set(struct, options \\ %{}) do
        IO.inspect("OPTIOTIOIT")
        IO.inspect(options)
        struct
        |> Map.merge(%{
          scheduled_at: if(options[:wait], do: options[:wait].seconds.from_now.to_f, else: nil),
          scheduled_at: if(options[:wait_until], do: options[:wait_until]),
          queue_name: if(options[:queue], do: self.class.queue_name_from_part(options[:queue])),
          priority: if(options[:priority], do: options[:priority].to_i)
        })
      end

      def serialize_arguments_if_needed(struct, arguments) do
        # if arguments_serialized?(struct) do
        #  struct.serialized_arguments
        # else
        #  serialize_arguments(struct, arguments)
        # end
      end

      def deserialize_arguments_if_needed(struct) do
        cond do
          arguments_serialized?(struct) ->
            struct
            |> Map.merge(%{
              arguments: struct.arguments, #deserialize_arguments(struct.serialized_arguments),
              serialized_arguments: nil
            })

          true ->
            struct
        end
      end

      def serialize_arguments(arguments) do
        arguments
        # Arguments.serialize(arguments)
      end

      def deserialize_arguments(serialized_args) do
        serialized_args
        # Arguments.deserialize(serialized_args)
      end

      def arguments_serialized?(struct) do
        cond do
          !(struct.serialized_arguments |> is_nil()) -> true
          true -> false
        end

        # defined?(@serialized_arguments) && @serialized_arguments
      end
    end
  end
end
