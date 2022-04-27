defmodule ActiveStorage.Blob.Identifiable do
  import Ecto.Changeset

  def identify(blob) do
    require IEx
    IEx.pry()
    identify_without_saving(blob)
    # identify_without_saving
    # save!
  end

  def identify_without_saving(blob) do
    if !identified?(blob) do
      IO.puts("TODO: IDENTIFY HERE")

      identifier_changeset(blob, %{
        content_type: "identify_content_type",
        identified: true
      })

      require IEx
      IEx.pry()
      #  self.content_type = identify_content_type
      #  self.identified = true
      blob
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
      :metadata
    ])
    |> prepare_changes(&set_metadata/1)
  end

  def set_metadata(current_changeset) do
    require IEx
    IEx.pry()

    put_change(
      current_changeset,
      :metadata,
      current_changeset
    )
  end

  def identified?(blob) do
    case blob.__struct__.metadata(blob) do
      %{"identified" => true} -> true
      _ -> false
    end
  end

  def identify_content_type(_blob) do
    # Marcel::MimeType.for download_identifiable_chunk, name: filename.to_s, declared_type: content_type
  end

  def download_identifiable_chunk(_blob) do
    # if byte_size.positive? do
    #  service.download_chunk key, 0...4.kilobytes
    # else
    #  ""
    # end
  end
end
