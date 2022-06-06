defmodule ActiveStorage.Attached.Changes.CreateOneOfMany do
  defstruct [:name, :record, :attachable, :blob, :attachment]

  def new(name, record, attachable) do
    struct = %__MODULE__{name: name, record: record, attachable: attachable}
    # @name, @record, @attachable = name, record, attachable
    blob = blob(struct)
    blob = blob.__struct__.identify_without_saving(blob)
    struct = struct |> Map.put(:blob, blob)
    struct
  end

  def find_attachment(instance) do
    instance.record
    |> Ecto.assoc(:"#{instance.name}_attachments")
    |> ActiveStorage.RepoClient.repo().all
    |> Enum.find(fn x -> x.blob_id == instance.blob.id end)

    # record.public_send("#{name}_attachments").detect { |attachment| attachment.blob_id == blob.id }
  end

  def attachment(instance) do
    # @attachment ||= find_or_build_attachment
    attachment = instance.attachment || find_or_build_attachment(instance)
    %{instance | attachment: attachment}
  end

  defdelegate blob(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate upload, to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate save(instance), to: ActiveStorage.Attached.Changes.CreateOne

  def find_or_build_attachment(instance) do
    find_attachment(instance) || build_attachment(instance)
  end

  # defdelegate find_attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate build_attachment(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate find_or_build_blob(instance), to: ActiveStorage.Attached.Changes.CreateOne

  defdelegate attachment_service_name(instance), to: ActiveStorage.Attached.Changes.CreateOne
end
