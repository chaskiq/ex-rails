defmodule ActiveJob.QueuePriority do
  # module QueuePriority

  # Includes the ability to override the default queue priority.
  # module ClassMethods
  # mattr_accessor :default_priority

  # Specifies the priority of the queue to create the job with.
  #
  #   class PublishToFeedJob < ActiveJob::Base
  #     queue_with_priority 50
  #
  #     def perform(post)
  #       post.to_feed!
  #     end
  #   end
  #
  # Specify either an argument or a block.
  def queue_with_priority(priority = nil, block \\ nil) do
    # if block_given?
    #  self.priority = block
    # else
    #  self.priority = priority
    # end
  end

  # end

  # included do
  #  class_attribute :priority, instance_accessor: false, default: default_priority
  # end

  # Returns the priority that the job will be created with
  def priority(struct) do
    # if @priority.is_a?(Proc)
    #  @priority = instance_exec(&@priority)
    # end
    # @priority
  end

  # end
end
