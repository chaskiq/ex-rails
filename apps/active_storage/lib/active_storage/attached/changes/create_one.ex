defmodule ActiveStorage.Attached.Changes.CreateOne do
  defstruct [:name, :record, :attachable, :blob, :attachment]

  def new(name, record, attachable) do
    struct = %__MODULE__{name: name, record: record, attachable: attachable}

    # @name, @record, @attachable = name, record, attachable
    blob =
      case blob(struct) do
        %ActiveStorage.Blob{} = blob -> blob
        blob -> blob.changes
      end

    blob = %ActiveStorage.Blob{} |> Map.merge(blob)
    blob = ActiveStorage.Blob.identify_without_saving(blob)

    struct = struct |> Map.put(:blob, blob)
    struct
  end

  def attachment(instance) do
    attachment = instance.attachment || find_or_build_attachment(instance)
    %{instance | attachment: attachment}
  end

  def blob(instance) do
    instance.blob || find_or_build_blob(instance)
  end

  def upload(instance, attachable = %ActiveStorage.Blob{}) do
    nil
  end

  def upload(instance, attachable) do
    ActiveStorage.Blob.upload_without_unfurling(
      instance.blob,
      attachable |> Keyword.get(:io)
    )

    # case attachable
    # when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
    #  blob.upload_without_unfurling(attachable.open)
    # when Hash
    #  blob.upload_without_unfurling(attachable.fetch(:io))
    # end
  end

  def save(instance) do
    name = :"#{instance.name}_attachment"
    blob_name = :"#{instance.name}_blob"

    rec =
      instance.record
      |> ActiveStorage.RepoClient.repo().preload([name, blob_name])

    # consider a Ecto MULTI transaction

    blob =
      case instance.blob do
        %Ecto.Changeset{valid?: true, data: _} ->
          # UPDATE CHANGESET
          instance.blob |> ActiveStorage.RepoClient.repo().update!

        %ActiveStorage.Blob{} = blob ->
          case blob do
            %{id: nil} = blob ->
              blob =
                blob
                |> Ecto.Changeset.change()
                |> ActiveStorage.RepoClient.repo().insert!

            %{id: id} = blob ->
              blob
          end

        _ ->
          nil
      end

    instance = %{instance | blob: blob}

    upload(instance, instance.attachable)

    record_changeset = Ecto.Changeset.change(rec)

    attachment = attachment(instance).attachment

    a =
      Ecto.Changeset.put_assoc(record_changeset, name, attachment)
      |> ActiveStorage.RepoClient.repo().update!
      |> Map.get(name)
      |> ActiveStorage.RepoClient.repo().preload(:blob)

    # record.public_send("#{name}_attachment=", attachment)
    # record.public_send("#{name}_blob=", blob)
  end

  def find_or_build_attachment(instance) do
    find_attachment(instance) || build_attachment(instance)
  end

  def find_attachment(instance) do
    blob =
      instance.record
      |> Ecto.assoc(:"#{instance.name}_blob")
      |> ActiveStorage.RepoClient.repo().one

    case blob do
      nil ->
        nil

      blob ->
        apply(instance.record.__struct__, "#{instance.name}_attachment")
    end

    # if instance.record.public_send("#{name}_blob") == blob do
    #  record.public_send("#{name}_attachment")
    # end
  end

  def build_attachment(instance) do
    ActiveStorage.Attachment.new(
      record: instance.record,
      name: instance.name,
      blob: instance.blob
    )
  end

  def find_or_build_blob(instance) do
    case instance.attachable do
      %ActiveStorage.Blob{} ->
        instance.attachable

      [head | tail] ->
        ActiveStorage.Blob.build_after_unfurling(
          %ActiveStorage.Blob{},
          instance.attachable
          |> Keyword.merge(
            record: instance.record,
            # attachment_service_name
            service_name: "local"
          )
        )
    end
  end

  def find_or_build_blob(instance = "nononon") do
    # case attachable
    # when ActiveStorage::Blob
    #  attachable
    # when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
    #  ActiveStorage::Blob.build_after_unfurling(
    #    io: attachable.open,
    #    filename: attachable.original_filename,
    #    content_type: attachable.content_type,
    #    record: record,
    #    service_name: attachment_service_name
    #  )
    # when Hash
    #  ActiveStorage::Blob.build_after_unfurling(
    #    **attachable.reverse_merge(
    #      record: record,
    #      service_name: attachment_service_name
    #    ).symbolize_keys
    #  )
    # when String
    #  ActiveStorage::Blob.find_signed!(attachable, record: record)
    # else
    #  raise ArgumentError, "Could not find or build blob: expected attachable, got #{attachable.inspect}"
    # end
  end

  def attachment_service_name(instance) do
    # record.attachment_reflections[name].options[:service_name]
  end
end
