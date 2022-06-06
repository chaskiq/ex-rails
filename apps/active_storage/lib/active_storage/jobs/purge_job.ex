defmodule ActiveStorage.PurgeJob do
  use ActiveJob.Base,
    queue_adapter: :inline,
    queue_as: ActiveStorage.queues()[:purge]

  # discard_on ActiveRecord::RecordNotFound
  # retry_on ActiveRecord::Deadlocked, attempts: 10, wait: :exponentially_longer

  def perform(blob) do
    # blob.purge
  end
end

# # Provides asynchronous purging of ActiveStorage::Blob records via ActiveStorage::Blob#purge_later.
# class ActiveStorage::PurgeJob < ActiveStorage::BaseJob
#   queue_as { ActiveStorage.queues[:purge] }
#
#   discard_on ActiveRecord::RecordNotFound
#   retry_on ActiveRecord::Deadlocked, attempts: 10, wait: :exponentially_longer
#
#   def perform(blob)
#     blob.purge
#   end
# end
