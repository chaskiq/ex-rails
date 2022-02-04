defmodule ActiveStorage.Blob.Identifiable do
  def identify(_blob) do
    # identify_without_saving
    # save!
  end

  def identify_without_saving(_blob) do
    # unless identified?
    #  self.content_type = identify_content_type
    #  self.identified = true
    # end
  end

  def identified?(blob) do
    blob.metadata.identified
  end

  defp identify_content_type(_blob) do
    # Marcel::MimeType.for download_identifiable_chunk, name: filename.to_s, declared_type: content_type
  end

  defp download_identifiable_chunk(_blob) do
    # if byte_size.positive? do
    #  service.download_chunk key, 0...4.kilobytes
    # else
    #  ""
    # end
  end
end
