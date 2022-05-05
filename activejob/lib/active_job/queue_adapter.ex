# frozen_string_literal: true

# require "active_support/core_ext/string/inflections"

defmodule ActiveJob.QueueAdapter do
  defmacro __using__(queue_adapter: queue_adapter) do
    quote do
      # extend ActiveSupport::Concern

      # included do
      #  class_attribute :_queue_adapter_name, instance_accessor: false, instance_predicate: false
      #  class_attribute :_queue_adapter, instance_accessor: false, instance_predicate: false

      #  delegate :queue_adapter, to: :class

      #  self.queue_adapter = :async
      # end

      # Includes the setter method for changing the active queue adapter.
      # Returns the backend queue provider. The default queue adapter
      # is the +:async+ queue. See QueueAdapters for more information.
      def queue_adapter() do
        # IO.inspect("QUEUE ADAPTER HERE")
        # IO.inspect("__MODULE__")
        # IO.inspect(unquote(queue_adapter))
        set_queue_adapter(unquote(queue_adapter))
        # IO.inspect(a)
        # IO.inspect("---")
        # _queue_adapter
      end

      # Returns string denoting the name of the configured queue adapter.
      # By default returns <tt>"async"</tt>.
      def queue_adapter_name() do
        # _queue_adapter_name
      end

      # Specify the backend queue provider. The default queue adapter
      # is the +:async+ queue. See QueueAdapters for more
      # information.
      #       def queue_adapter=(name_or_adapter)

      def set_queue_adapter(name_or_adapter) do
        # IO.inspect("SET ADAPTER: ")
        # IO.inspect(name_or_adapter)

        # :ets.new(:user_lookup, [:set, :protected, :named_table])
        mod =
          cond do
            name_or_adapter |> Code.ensure_loaded?() ->
              name_or_adapter

            name_or_adapter |> is_atom ->
              mod = ActiveJob.QueueAdapters.lookup(name_or_adapter)

            # if queue_adapter?(mod) do
            #  mod
            # else
            #  raise ArgumentError
            # end

            true ->
              raise ArgumentError
          end

        #
        mod.new

        # case name_or_adapter
        # when Symbol, String
        #   queue_adapter = ActiveJob::QueueAdapters.lookup(name_or_adapter).new
        #   assign_adapter(name_or_adapter.to_s, queue_adapter)
        # else
        #   if queue_adapter?(name_or_adapter)
        #     adapter_name = "#{name_or_adapter.class.name.demodulize.remove('Adapter').underscore}"
        #     assign_adapter(adapter_name, name_or_adapter)
        #   else
        #     raise ArgumentError
        #   end
        # end
      end

      defp assign_adapter(adapter_name, queue_adapter) do
        # :ets.insert(:user_lookup, {
        #  "doomspork",
        #  "Sean",
        #  ["Elixir", "Ruby", "Java"]
        # })

        # self._queue_adapter_name = adapter_name
        # self._queue_adapter = queue_adapter
      end

      # QUEUE_ADAPTER_METHODS = [:enqueue, :enqueue_at].freeze
      @queue_adapter_methods [:enqueue, :enqueue_at]

      def queue_adapter?(object) do
        @queue_adapter_methods
        |> Enum.all?(fn meth -> function_exported?(object, meth, 2) end)

        # QUEUE_ADAPTER_METHODS.all? { |meth| object.respond_to?(meth) }
      end
    end
  end
end
