defmodule ActiveStorage do
  @moduledoc """
  The ActiveStorage context.
  """

  import Ecto.Query, warn: false
  alias Chaskiq.Repo

  alias ActiveStorage.{Attachment, Blob}

  def verifier do
    Chaskiq.Verifier
  end

  def graphql_resolver(
        _a,
        %{
          input:
            %{
              byte_size: _byte_size,
              checksum: _checksum,
              content_type: _content_type,
              filename: _filename
            } = input
        },
        %{context: %{current_user: _current_user}}
      ) do
    direct_upload_response = %{direct_upload: create_direct_upload(input)}

    {:ok, direct_upload_response}
  end

  def create_direct_upload(%{
        byte_size: byte_size,
        checksum: checksum,
        content_type: content_type,
        filename: filename
      }) do
    service = "amazon"

    {:ok, blob} =
      ActiveStorage.create_storage_blob(%{
        byte_size: byte_size,
        checksum: checksum,
        content_type: content_type,
        filename: filename,
        metadata: %{},
        service_name: service
      })

    _service = blob |> ActiveStorage.Blob.service()

    ActiveStorage.Service.S3Service.create_direct_upload(blob, %{
      byte_size: byte_size,
      checksum: checksum,
      content_type: content_type,
      filename: filename
    })
  end

  # def url(blob) do
  #  service(blob).url(blob)
  # end

  def url(blob) do
    ActiveStorage.Service.url(blob)
  end

  def service_url(blob) do
    signed_blob_id = Chaskiq.Verifier.sign(blob.id)
    "/active_storage/blobs/redirect/#{signed_blob_id}"
  end

  @doc """
  Returns the list of storage_blob.

  ## Examples

      iex> list_storage_blob()
      [%Blob{}, ...]

  """
  def list_storage_blob do
    Repo.all(Blob)
  end

  @doc """
  Gets a single storage_blob.

  Raises `Ecto.NoResultsError` if the Storage blob does not exist.

  ## Examples

      iex> get_storage_blob!(123)
      %Blob{}

      iex> get_storage_blob!(456)
      ** (Ecto.NoResultsError)

  """
  def get_storage_blob!(id), do: Repo.get!(Blob, id)

  @doc """
  Creates a storage_blob.

  ## Examples

      iex> create_storage_blob(%{field: value})
      {:ok, %Blob{}}

      iex> create_storage_blob(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_storage_blob(attrs \\ %{}) do
    %Blob{}
    |> Blob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a storage_blob.

  ## Examples

      iex> update_storage_blob(storage_blob, %{field: new_value})
      {:ok, %Blob{}}

      iex> update_storage_blob(storage_blob, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_storage_blob(%Blob{} = storage_blob, attrs) do
    storage_blob
    |> Blob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a storage_blob.

  ## Examples

      iex> delete_storage_blob(storage_blob)
      {:ok, %Blob{}}

      iex> delete_storage_blob(storage_blob)
      {:error, %Ecto.Changeset{}}

  """
  def delete_storage_blob(%Blob{} = storage_blob) do
    Repo.delete(storage_blob)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking storage_blob changes.

  ## Examples

      iex> change_storage_blob(storage_blob)
      %Ecto.Changeset{data: %Blob{}}

  """
  def change_storage_blob(%Blob{} = storage_blob, attrs \\ %{}) do
    Blob.changeset(storage_blob, attrs)
  end

  @doc """
  Gets a single attachment.

  Raises `Ecto.NoResultsError` if the attachment does not exist.

  ## Examples

      iex> get_attachment(123)
      %Blob{}

      iex> get_attachment(456)
      ** (Ecto.NoResultsError)

  """
  def get_attachment!(record_type, record_id) do
    from(a in Attachment, where: a.record_type == ^record_type and a.record_id == ^record_id)
    |> preload(:blob)
    |> repo().one!()
  end

  defp repo do
    Application.fetch_env!(:ex_active_storage, :repo)
  end

  # Downloads the blob to a tempfile on disk. Yields the tempfile.
  #
  # The tempfile's name is prefixed with +ActiveStorage-+ and the blob's ID. Its extension matches that of the blob.
  #
  # By default, the tempfile is created in <tt>Dir.tmpdir</tt>. Pass +tmpdir:+ to create it in a different directory:
  #
  #   blob.open(tmpdir: "/path/to/tmp") do |file|
  #     # ...
  #   end
  #
  # The tempfile is automatically closed and unlinked after the given block is executed.
  #
  # Raises ActiveStorage::IntegrityError if the downloaded data does not match the blob's checksum.
  # def open(tmpdir: nil, &block) do
  # service.open(
  #   key,
  #   checksum: checksum,
  #   verify: !composed,
  #   name: [ "ActiveStorage-#{id}-", filename.extension_with_delimiter ],
  #   tmpdir: tmpdir,
  #   &block
  # )
  # end

  # def mirror_later # :nodoc:
  #  ActiveStorage::MirrorJob.perform_later(key, checksum: checksum) if service.respond_to?(:mirror)
  # end

  def variable_content_types,
    do: [
      "image/png",
      "image/gif",
      "image/jpg",
      "image/jpeg",
      "image/pjpeg",
      "image/tiff",
      "image/bmp",
      "image/vnd.adobe.photoshop",
      "image/vnd.microsoft.icon",
      "image/webp"
    ]

  def web_image_content_types,
    do: [
      "image/png",
      "image/jpeg",
      "image/jpg",
      "image/gif"
    ]

  def content_types_to_serve_as_binary,
    do: [
      "text/html",
      "text/javascript",
      "image/svg+xml",
      "application/postscript",
      "application/x-shockwave-flash",
      "text/xml",
      "application/xml",
      "application/xhtml+xml",
      "application/mathml+xml",
      "text/cache-manifest"
    ]

  def content_types_allowed_inline,
    do: [
      "image/png",
      "image/gif",
      "image/jpg",
      "image/jpeg",
      "image/tiff",
      "image/bmp",
      "image/vnd.adobe.photoshop",
      "image/vnd.microsoft.icon",
      "application/pdf"
    ]

  def previewers,
    do: [
      ActiveStorage.Previewer.PopplerPDFPreviewer,
      ActiveStorage.Previewer.MuPDFPreviewer,
      ActiveStorage.Previewer.VideoPreviewer
    ]

  def analyzers,
    do: [ActiveStorage.Analyzer.ImageAnalyzer, ActiveStorage.Analyzer.VideoAnalyzer]

  # def paths, do: ActiveSupport :: OrderedOptions.new()
  # def queues, do: ActiveSupport :: InheritableOptions.new()
end
