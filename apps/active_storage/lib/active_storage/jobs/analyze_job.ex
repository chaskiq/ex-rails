defmodule ActiveStorage.AnalyzeJob do
  use ActiveJob.Base,
    queue_adapter: :inline,
    queue_as: ActiveStorage.queues()[:analysis]

  # discard_on ActiveRecord::RecordNotFound
  # retry_on ActiveStorage::IntegrityError, attempts: 10, wait: :exponentially_longer
  # callbacks: %{
  #  before: fn x -> IO.inspect("BEFORE") end,
  #  after: fn x -> IO.inspect("AFTER") end
  # }

  def perform(%{blob_id: blob_id}) do
    blob = ActiveStorage.get_storage_blob!(blob_id)
    ActiveStorage.Blob.analyze(blob)
    # blob.analyze
  end
end

# Provides asynchronous analysis of ActiveStorage::Blob records via ActiveStorage::Blob#analyze_later.
# class ActiveStorage::AnalyzeJob < ActiveStorage::BaseJob
#   queue_as { ActiveStorage.queues[:analysis] }
#
#   discard_on ActiveRecord::RecordNotFound
#   retry_on ActiveStorage::IntegrityError, attempts: 10, wait: :exponentially_longer
#
#   def perform(blob)
#     blob.analyze
#   end
# end
