defmodule ActiveStorage.Attached.Changes.CreateOneOfMany do
  defstruct [:name, :record, :attachable, :blob]

  # < Attached::Changes::CreateOne # :nodoc:
  #  private
  #    def find_attachment
  #      record.public_send("#{name}_attachments").detect { |attachment| attachment.blob_id == blob.id }
  #    end

  def find_attachment(instance) do
    attachment_name = String.to_atom("#{instance.name}_blobs")
    blob_name = String.to_atom("#{instance.name}_blob")

    rec =
      instance.record
      |> ActiveStorage.RepoClient.repo().preload([attachment_name, blob_name])

    require IEx
    IEx.pry()

    rec

    # record.public_send("#{name}_attachments").detect { |attachment| attachment.blob_id == blob.id }
  end

  defdelegate new(name, record, attachable), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate blob(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate upload, to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate save(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate find_or_build_attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  # defdelegate find_attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate build_attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate find_or_build_blob(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate attachment_service_name(instance), to: ActiveStorage.Attached.Changes.CreateOne
end
