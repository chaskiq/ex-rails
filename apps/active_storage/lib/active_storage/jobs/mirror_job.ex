defmodule ActiveStorage.MirrorJob do
  use ActiveJob.Base,
    queue_adapter: :inline,
    queue_as: ActiveStorage.queues()[:mirror]

  # discard_on ActiveStorage::FileNotFoundError
  # retry_on ActiveStorage::IntegrityError, attempts: 10, wait: :exponentially_longer

  def perform(key, options \\ []) do
    defaults = [checksum: nil]
    # ActiveStorage.Blob.service.try(:mirror, key, checksum: checksum)
  end
end

# require "active_support/core_ext/object/try"
#
# # Provides asynchronous mirroring of directly-uploaded blobs.
# class ActiveStorage::MirrorJob < ActiveStorage::BaseJob
#   queue_as { ActiveStorage.queues[:mirror] }
#
#   discard_on ActiveStorage::FileNotFoundError
#   retry_on ActiveStorage::IntegrityError, attempts: 10, wait: :exponentially_longer
#
#   def perform(key, checksum:)
#     ActiveStorage::Blob.service.try(:mirror, key, checksum: checksum)
#   end
# end
