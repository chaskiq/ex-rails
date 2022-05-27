defmodule ActiveJob.Execution do
  defmacro __using__(opts) do
    quote do
      # extend ActiveSupport::Concern
      # include ActiveSupport::Rescuable

      # Includes methods for executing and performing jobs instantly.
      # ClassMethods
      # Performs the job immediately.
      #
      #   MyJob.perform_now("mike")
      #
      def perform_now(args) do
        job = job_or_instantiate(args)
        job.__struct__._perform_now(job)
      end

      def execute(struct, job_data) do
        IO.inspect("EXECUTE HERE!")
        struct.__struct__.perform_now(struct)
        # ActiveJob.Callbacks.run_callbacks(:execute) do
        #  job = deserialize(job_data)
        #  job.perform_now
        # end
      end

      # Performs the job immediately. The job is not sent to the queuing adapter
      # but directly executed by blocking the execution of others until it's finished.
      # +perform_now+ returns the value of your job's +perform+ method.
      #
      #   class MyJob < ActiveJob::Base
      #     def perform
      #       "Hello World!"
      #     end
      #   end
      #
      #   puts MyJob.new(*args).perform_now # => "Hello World!"
      def _perform_now(struct) do
        IO.inspect("PERFORM NOW!")
        # IO.inspect(struct)

        #  # Guard against jobs that were persisted before we started counting executions by zeroing out nil counters
        #  self.executions = (executions || 0) + 1

        #  deserialize_arguments_if_needed

        #  _perform_job
        struct.__struct__._perform_job(struct)
        # rescue Exception => exception
        #  rescue_with_handler(exception) || raise
      end

      def perform(struct, any) do
        # fail NotImplementedError
      end

      def _perform_job(struct) do
        struct.__struct__.perform(struct.arguments)
        # ActiveSupport::ExecutionContext[:job] = self
        # run_callbacks :perform do
        #  perform(*arguments)
        # end
      end
    end
  end
end
