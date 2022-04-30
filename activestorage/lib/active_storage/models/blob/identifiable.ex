defmodule ActiveStorage.Blob.Identifiable do
  import Ecto.Changeset

  def identify(blob) do
    a = identify_without_saving(blob)
    require IEx
    IEx.pry()
    # identify_without_saving
    # save!
  end

  def identify_without_saving(blob) do
    if !identified?(blob) do
      identifier_changeset(blob, %{
        content_type: identify_content_type(blob),
        metadata:
          Jason.encode!(%{
            identified: true
          })
      })

      # blob
      #  self.content_type = identify_content_type
      #  self.identified = true
      # blob
    else
      blob
    end

    # unless identified?
    #  self.content_type = identify_content_type
    #  self.identified = true
    # end
  end

  def identifier_changeset(blob, attrs) do
    blob
    |> cast(attrs, [
      :metadata,
      :content_type
    ])
    |> metadata_handler(attrs)
  end

  def metadata_handler(current_changeset, attrs) do
    current_changeset
    |> put_change(
      :metadata,
      attrs.metadata
    )
    |> put_change(
      :content_type,
      attrs.content_type
    )
  end

  def update_metadata(blob, attrs) do
  end

  def identified?(blob) do
    case blob.__struct__.metadata(blob) do
      %{"identified" => true} -> true
      _ -> false
    end
  end

  def identify_content_type(blob) do
    # , name: filename.to_s, declared_type: content_type)
    case download_identifiable_chunk(blob) |> ExImageInfo.type() do
      {type, _} -> type
      _ -> nil
    end

    # ExImageInfo.type File.read! __MODULE__.path_for(service, key)
    # Marcel::MimeType.for download_identifiable_chunk, name: filename.to_s, declared_type: content_type
  end

  def download_identifiable_chunk(blob) do
    if blob.byte_size > 0 do
      blob.__struct__.service(blob)
      service = blob.__struct__.service(blob)
      service.__struct__.download_chunk(service, blob.key, 0..4096)
    else
      ""
    end

    # if byte_size.positive? do
    #  service.download_chunk key, 0...4.kilobytes
    # else
    #  ""
    # end
  end
end
