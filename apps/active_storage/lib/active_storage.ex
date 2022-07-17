defmodule ActiveStorage do
  @moduledoc """
  The ActiveStorage context.
  """

  import Ecto.Query, warn: false

  alias ActiveStorage.{Attachment, Blob, Service, Verifier}

  def verifier do
    Verifier
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

  def url(blob, options \\ []) do
    defaults = [
      filename: ActiveStorage.Blob.filename(blob)
    ]

    options = Keyword.merge(defaults, options)

    ActiveStorage.Service.url(blob, options)
  end

  def service_url(blob) do
    ActiveStorage.Service.service_url(blob)
  end

  def routes_prefix do
    Application.get_env(:active_storage, :routes_prefix) || "/active_storage"
  end

  def service_blob_url(struct, _opts \\ []) do
    namespace = routes_prefix()

    # expires_in =
    #  Keyword.fetch!(opts, :expires_in) ||
    #    Application.get_env(:active_storage, :urls_expire_in)

    # sign_option = [expires_in: 3600]
    sign_option = []

    case struct do
      %ActiveStorage.Variant{blob: blob} ->
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.VariantWithRecord{blob: blob} ->
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.Preview{blob: blob} ->
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.Blob{} = blob ->
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.Attachment{} ->
        "url!"

      _ ->
        nil
    end
  end

  def blob_proxy_url(struct, _opts \\ []) do
    namespace = routes_prefix()
    # sign_option = [expires_in: 3600]
    sign_option = []

    case struct do
      %ActiveStorage.Blob{} = blob ->
        filename = Blob.filename(blob)
        "#{namespace}/blobs/proxy/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      _ ->
        nil
    end
  end

  def storage_redirect_url(struct, opts \\ []) do
    namespace = routes_prefix()

    # sign_option = [expires_in: 3600]
    sign_option = []

    case struct do
      %ActiveStorage.Variant{blob: blob} ->
        service_blob_url(blob)

      %ActiveStorage.VariantWithRecord{blob: blob} = variant ->
        # "/representations/redirect/:signed_blob_id/:variation_key/*filename" => "active_storage/representations/redirect#show", as: :rails_blob_representation
        variation_key = variant.variation.__struct__.key(variant.variation)

        "#{namespace}/representations/redirect/#{Blob.signed_id(blob, sign_option)}/#{variation_key}/#{Blob.filename(blob).filename}"

      %ActiveStorage.Preview{blob: blob} ->
        require IEx
        IEx.pry()
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.Blob{} = blob ->
        require IEx
        IEx.pry()
        filename = Blob.filename(blob)
        "#{namespace}/blobs/redirect/#{Blob.signed_id(blob, sign_option)}/#{filename.filename}"

      %ActiveStorage.Attachment{} ->
        require IEx
        IEx.pry()
        "url!"

      _ ->
        nil
    end
  end

  @doc """
  Returns the list of storage_blob.

  ## Examples

      iex> list_storage_blob()
      [%Blob{}, ...]

  """
  def list_storage_blob do
    repo().all(Blob)
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
  def get_storage_blob!(id), do: repo().get!(Blob, id)

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
    |> repo().insert()
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
    |> repo().update()
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
    repo().delete(storage_blob)
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
  Gets a record's attachment.

  Returns `nil` if attachment doesn't exist.

  ## Examples

      iex> get_attachment(user, "avatar")
      %ActiveStorage.Attachment{}
  """
  def get_attachment(record, attachment_name) do
    attachment_query(record, attachment_name)
    |> preload(:blob)
    |> repo().one()
  end

  def get_attachments(record, attachment_name) do
    attachment_query(record, attachment_name)
    |> preload(:blob)
    |> repo().all()
  end

  @doc """
  Checks if attachment(s) exists (works for `has_one_attached` and `has_many_attached`).

  ## Examples

      iex> attached?(user, "avatar")
      true
  """
  def attached?(record, attachment_name) do
    attachment_query(record, attachment_name) |> repo().exists?
  end

  @doc """
  Remove attachment from database as well as the actual resource file.  Done in a transaction so that
  nothing is left dangling.
  """
  def purge_attachment(record, attachment_name) do
    attachment = get_attachment(record, attachment_name)

    repo().delete(attachment)
    repo().delete(%Blob{id: attachment.blob_id})

    Service.delete(attachment)
  end

  def url_for_attachment(attachment, opts \\ []), do: Service.url(attachment, opts)

  def attachment_query(%mod{id: record_id}, attachment_name) do
    record_type = mod.record_type()

    from(a in Attachment,
      where:
        a.name == ^attachment_name and
          a.record_type == ^record_type and
          a.record_id == ^record_id
    )
  end

  def repo do
    Application.fetch_env!(:active_storage, :repo)
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

  # ActiveStorage.video_preview_arguments = app.config.active_storage.video_preview_arguments || "-y -vframes 1 -f image2"

  def video_preview_arguments() do
    # "-y -vframes 1 -f image2"
    "-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"
  end

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
      "image/psd",
      "image/vnd.microsoft.icon",
      "image/webp",
      "image/psd",
      "image/x-icon"
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
    do: [
      ActiveStorage.Analyzer.ImageAnalyzer,
      ActiveStorage.Analyzer.VideoAnalyzer,
      ActiveStorage.Analyzer.AudioAnalyzer
    ]

  def paths,
    do: [
      ffmpeg: "ffmpeg",
      ffprobe: "ffprobe",
      pdftoppm: "pdftoppm"
      # ffmpeg: "/usr/local/bin/ffmpeg",
      # ffprobe: "/usr/local/bin/ffprobe",
      # pdftoppm: "/usr/local/bin/pdftoppm"
    ]

  def track_variants() do
    ActiveStorage.TableConfig.get("track_variants")
  end

  # def paths, do: ActiveSupport :: OrderedOptions.new()
  # def queues, do: ActiveSupport :: InheritableOptions.new()
end
