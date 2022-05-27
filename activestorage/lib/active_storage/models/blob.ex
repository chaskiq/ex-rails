defmodule ActiveStorage.Blob do
  use Ecto.Schema
  import Ecto.Changeset
  import ActiveStorage.{RepoClient}
  # import ActiveStorage.Blob.Representable
  # import ActiveStorage.Blob.Identifiable
  # import ActiveStorage.Blob.Analyzable
  use ActiveStorage.Blob.Analyzable

  use ActiveStorage.Attached.Model
  use ActiveStorage.Attached.HasOne, name: :preview_image, model: "Blob"

  # @foreign_key_type :binary_id
  schema "active_storage_blobs" do
    field(:byte_size, :integer)
    field(:checksum, :string)
    field(:content_type, :string)
    field(:filename, :string)
    field(:key, :string)

    # I wasn't able to get the JSON to render.  Error:
    # cannot load `"{\"identified\":true,\"analyzed\":true}"` as type :map for field :metadata in %ActiveStorage.Blob{...
    # --->> this field is text, so the problem is that it can be handled as a map. but we could cast it on a changeset.
    field(:metadata, :string)
    field(:service_name, :string)

    has_many(:variant_records, ActiveStorage.VariantRecord)
    # before_destroy { variant_records.destroy_all if ActiveStorage.track_variants }
    # has_one_attached :preview_image

    has_one(:preview_image_attachment, ActiveStorage.Attachment,
      where: [record_type: "Blob"],
      foreign_key: :record_id
    )

    has_one(:preview_image_blob, through: [:preview_image_attachment, :blob])

    timestamps(inserted_at: :created_at, updated_at: :updated_at)
  end

  def record_type do
    "Blob"
  end

  @doc false
  def changeset(storage_blob, attrs) do
    storage_blob
    |> cast(attrs, [
      :filename,
      :content_type,
      :metadata,
      :byte_size,
      :checksum,
      :service_name,
      :key
    ])
    |> key
    # |> prepare_changes(&set_defaults/1)
    |> validate_required([
      :filename,
      :content_type,
      # :metadata,
      # :byte_size,
      # :checksum,
      :service_name
    ])
  end

  def set_defaults(current_changeset) do
    cond do
      current_changeset.changes |> Map.get(:key) ->
        current_changeset

      true ->
        current_changeset
        |> key()
    end
  end

  # To prevent problems with case-insensitive filesystems, especially in combination
  # with databases which treat indices as case-sensitive, all blob keys generated are going
  # to only contain the base-36 character alphabet and will therefore be lowercase. To maintain
  # the same or higher amount of entropy as in the base-58 encoding used by `has_secure_token`
  # the number of bytes used is increased to 28 from the standard 24
  # def generate_unique_secure_token(length: MINIMUM_TOKEN_LENGTH)
  #  SecureRandom.base36(length)
  # end
  def generate_unique_secure_token(current_changeset, _length) do
    # binary = Ecto.UUID.bingenerate()
    # {:ok, k} = Ecto.UUID.load(binary)
    put_change(
      current_changeset,
      :key,
      SecureRandom.urlsafe_base64(13) |> String.downcase() |> String.replace("=", "")
    )
  end

  # Returns the key pointing to the file on the service that's associated with this blob. The key is the
  # secure-token format from Rails in lower case. So it'll look like: xtapjjcjiudrlk3tmwyjgpuobabd.
  # This key is not intended to be revealed directly to the user.
  # Always refer to blobs using the signed_id or a verified form of the key.
  def key(changeset) do
    # We can't wait until the record is first saved to have a key for it
    case changeset.changes |> Map.get(:key) do
      nil ->
        case changeset.data |> Map.get(:key) do
          nil -> generate_unique_secure_token(changeset, length: 2)
          _ -> changeset
        end

      _ ->
        changeset
    end
  end

  def creation_changeset(storage_blob, attrs) do
    storage_blob
    |> cast(attrs, [
      :filename,
      :content_type,
      :metadata,
      :byte_size,
      :checksum,
      :service_name
    ])
    |> validate_required([
      :filename,
      :content_type,
      :metadata,
      :byte_size,
      :checksum,
      :service_name,
      :key
    ])
  end

  # active storage ported methods

  def build_after_unfurling(blob, options \\ []) do
    defaults = [
      key: nil,
      io: nil,
      filename: nil,
      content_type: nil,
      metadata: nil,
      service_name: "local",
      identify: true
      # record: record
    ]

    options = Keyword.merge(defaults, options)

    n =
      blob
      |> ActiveStorage.Blob.changeset(%{
        byte_size: options[:byte_size],
        checksum: options[:checksum],
        content_type: options[:content_type],
        filename: options[:filename],
        key: options[:key],
        metadata: options[:metadata],
        service_name: options[:service_name]
      })

    n |> unfurl(options[:io], identify: options[:identify])

    # new(key: key, filename: filename, content_type: content_type, metadata: metadata, service_name: service_name).tap do |blob|
    #  blob.unfurl(io, identify: identify)
    # end
  end

  def create_after_unfurling!(blob, options \\ []) do
    defaults = [
      key: nil,
      io: nil,
      filename: nil,
      content_type: nil,
      metadata: nil,
      service_name: "local",
      identify: true
      # record: record
    ]

    options = Keyword.merge(defaults, options)

    build_after_unfurling(blob, options)
    |> repo().insert!()

    # changeset.tap(&:save!)
  end

  # Creates a new blob instance and then uploads the contents of
  # the given <tt>io</tt> to the service. The blob instance is going to
  # be saved before the upload begins to prevent the upload clobbering another due to key collisions.
  # When providing a content type, pass <tt>identify: false</tt> to bypass
  # automatic content type inference.
  def create_and_upload!(blob, options \\ []) do
    defaults = [
      key: nil,
      io: nil,
      filename: nil,
      content_type: nil,
      metadata: nil,
      service_name: "local",
      identify: true
      # record: record
    ]

    options = Keyword.merge(defaults, options)

    create_after_unfurling!(blob,
      key: options[:key],
      io: options[:io],
      filename: options[:filename],
      content_type: options[:content_type],
      metadata: options[:metadata],
      service_name: options[:service_name],
      identify: options[:identify]
    )
    |> upload_without_unfurling(options[:io])

    # create_after_unfurling!(%{key: key, io: io, filename: filename, content_type: content_type, metadata: metadata, service_name: service_name, identify: identify}) .tap do |blob|
    #  blob.upload_without_unfurling(io)
    # end
  end

  # Returns a saved blob _without_ uploading a file to the service. This blob will point to a key where there is
  # no file yet. It's intended to be used together with a client-side upload, which will first create the blob
  # in order to produce the signed URL for uploading. This signed URL points to the key generated by the blob.
  # Once the form using the direct upload is submitted, the blob can be associated with the right record using
  # the signed ID.
  def create_before_direct_upload!(options \\ []) do
    defaults = [
      key: nil,
      io: nil,
      filename: nil,
      content_type: nil,
      metadata: nil,
      service_name: "local",
      identify: true,
      record: nil
    ]

    options = Keyword.merge(defaults, options)
    args = Enum.into(options, %{})

    __MODULE__.changeset(%__MODULE__{}, args) |> repo().insert!

    # create! key: key, filename: filename, byte_size: byte_size, checksum: checksum, content_type: content_type, metadata: metadata, service_name: service_name
  end

  # Uploads the +io+ to the service on the +key+ for this blob. Blobs are intended to be immutable, so you shouldn't be
  # using this method after a file has already been uploaded to fit with a blob. If you want to create a derivative blob,
  # you should instead simply create a new blob based on the old one.
  #
  # Prior to uploading, we compute the checksum, which is sent to the service for transit integrity validation. If the
  # checksum does not match what the service receives, an exception will be raised. We also measure the size of the +io+
  # and store that in +byte_size+ on the blob record. The content type is automatically extracted from the +io+ unless
  # you specify a +content_type+ and pass +identify+ as false.
  #
  # Normally, you do not have to call this method directly at all. Use the +create_and_upload!+ class method instead.
  # If you do use this method directly, make sure you are using it on a persisted Blob as otherwise another blob's
  # data might get overwritten on the service.
  def upload(blob, io, options \\ []) do
    defaults = [identify: true]
    options = Keyword.merge(defaults, options)

    blob
    |> unfurl(io, options)
    |> upload_without_unfurling(io)
  end

  # Deletes the files on the service associated with the blob. This should only be done if the blob is going to be
  # deleted as well or you will essentially have a dead reference. It's recommended to use #purge and #purge_later
  # methods in most circumstances.
  def delete(service, blob) do
    service.__struct__.delete(service, blob.key)

    if image?(blob) do
      service.__struct__.delete_prefixed("variants/#{blob.key}/")
    end
  end

  # Destroys the blob record and then deletes the file on the service. This is the recommended way to dispose of unwanted
  # blobs. Note, though, that deleting the file off the service will initiate an HTTP connection to the service, which may
  # be slow or prevented, so you should not use this method inside a transaction or in callbacks. Use #purge_later instead.
  def purge(blob) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:blob, fn repo, _changes ->
      case ActiveStorage.RepoClient.repo().get(__MODULE__, blob.id) do
        nil -> {:error, :not_found}
        blob -> {:ok, blob}
      end
    end)
    |> Ecto.Multi.delete(:delete, fn %{blob: blob} ->
      # Others validations
      blob
    end)
    # |> Multi.insert(:log, Log.password_reset_changeset(account, params))
    # |> Multi.delete_all(:sessions, assoc(account, :sessions))
    |> ActiveStorage.RepoClient.repo().transaction()

    # case ActiveStorage.RepoClient.repo().delete(blob) do
    #  # Deleted with success
    #  {:ok, struct} ->
    #    service = service(struct)
    #    delete(service, blob)
    #    struct

    #  # Something went wrong
    #  {:error, changeset} ->
    #    changeset
    # end

    # destroy
    # delete if previously_persisted?
    # rescue ActiveRecord::InvalidForeignKey
  end

  # Enqueues an ActiveStorage::PurgeJob to call #purge. This is the recommended way to purge blobs from a transaction,
  # an Active Record callback, or in any other real-time scenario.
  def purge_later(blob) do
    ActiveStorage.PurgeJob.perform_later(blob)
  end

  def service(blob) do
    # Application.get_env(:active_storage, :storage)
    # |> Keyword.get(blob.service_name |> String.to_existing_atom())
    ActiveStorage.Service.Registry.fetch(blob.service_name)
    # services.fetch(blob.service_name)
  end

  # :nodoc:
  def unfurl(blob, io, options \\ []) do
    defaults = [identify: true]

    options = Keyword.merge(defaults, options)

    checksum = compute_checksum_in_chunks(io)
    # ExImageInfo.seems?(io)

    bite_size = get_byte_size(io)

    data = %{
      byte_size: bite_size,
      metadata: Jason.encode!(%{identified: true}),
      checksum: checksum
    }

    data =
      if options[:identify] do
        content_type = extract_content_type(blob, io)
        data |> Map.merge(%{content_type: content_type})
      else
        content_type = MIME.from_path(blob.changes.filename)
        data |> Map.merge(%{content_type: content_type})
      end

    __MODULE__.changeset(%__MODULE__{}, blob.changes |> Map.merge(data))

    # content_type = extract_content_type(io) if content_type.nil? || identify
    # byte_size    = io.size
    # identified   = true
  end

  def compose(_blob, _keys) do
    # self.composed = true
    # service.compose(keys, key, **service_metadata)
  end

  def upload_without_unfurling(blob, io) do
    srv = blob |> service
    mod = srv.__struct__

    case mod.upload(srv, blob.key, io) do
      {:ok, _response} ->
        blob

      {:error, err} ->
        IO.inspect(err)
        nil
    end

    # srv.upload(blob, "./README.md")
    # service.upload key, io, checksum: checksum, **service_metadata
  end

  # Downloads the file associated with this blob. If no block is given, the entire file is read into memory and returned.
  # That'll use a lot of RAM for very large files. If a block is given, then the download is streamed and yielded in chunks.
  def download(blob, block \\ nil) do
    s = service(blob)
    s.__struct__.download(s, blob.key, block)
  end

  def get_byte_size(io) do
    <<head::size(8), _rest::binary>> = io
    head
  end

  def compute_checksum_in_chunks(io) do
    :crypto.hash(:md5, io) |> Base.encode64()
    # OpenSSL::Digest::MD5.new.tap do |checksum|
    #  while chunk = io.read(5.megabytes)
    #    checksum << chunk
    #  end
    #  io.rewind
    # end.base64digest
  end

  # Returns an ActiveStorage::Filename instance of the filename that can be
  # queried for basename, extension, and a sanitized version of the filename
  # that's safe to use in URLs.
  def filename(blob) do
    ActiveStorage.Filename.new(blob.filename)
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
  # , tmpdir: nil, fn) do
  def open(blob, options \\ []) do
    defaults = [tmpdir: nil, block: nil]
    options = Keyword.merge(defaults, options)

    ext = MIME.extensions(MIME.from_path(blob.filename)) |> hd

    name = ["ActiveStorage-#{blob.id}-", ".#{ext}"]

    service = service(blob)

    service.__struct__.open(service, blob.key,
      checksum: blob.checksum,
      tmpdir: options[:tmpdir],
      name: name,
      block: options[:block]
    )

    # service.open blob.key, checksum: blob.checksum,
    #  name: [ "ActiveStorage-#{id}-", blob.filename.extension_with_delimiter ], tmpdir: tmpdir, &block
  end

  def extract_content_type(blob, io) do
    case ExImageInfo.info(io) do
      nil ->
        MIME.from_path(blob.changes.filename)

      {mime, _w, _h, _} ->
        mime
    end

    # Marcel::MimeType.for io, name: filename.to_s, declared_type: content_type
  end

  def forcibly_serve_as_binary?(blob) do
    ActiveStorage.content_types_to_serve_as_binary() |> Enum.member?(blob.content_type)
  end

  def allowed_inline?(blob) do
    ActiveStorage.content_types_allowed_inline() |> Enum.member?(blob.content_type)
  end

  def web_image?(blob) do
    ActiveStorage.web_image_content_types() |> Enum.member?(blob.content_type)
  end

  # Returns true if the content_type of this blob is in the image range, like image/png.
  def image?(blob) do
    blob.content_type |> String.starts_with?("image")
  end

  # Returns true if the content_type of this blob is in the audio range, like audio/mpeg.
  def audio?(blob) do
    blob.content_type |> String.starts_with?("audio")
  end

  # Returns true if the content_type of this blob is in the video range, like video/mp4.
  def video?(blob) do
    blob.content_type |> String.starts_with?("video")
  end

  # Returns true if the content_type of this blob is in the text range, like text/plain.
  def text?(blob) do
    blob.content_type |> String.starts_with?("text")
  end

  def record_type() do
    "blob"
  end

  def signed_id(blob, opts \\ []) do
    defaults = [expires_in: nil]
    options = Keyword.merge(defaults, opts)
    ActiveStorage.Verifier.sign(blob.id, options)
  end

  def find_signed(signed_id, purpose \\ nil) do
    case ActiveStorage.Verifier.verify(signed_id, purpose) do
      {:ok, id} ->
        ActiveStorage.get_storage_blob!(id)

      {:error, message} ->
        IO.puts("ERROR: #{message}")
        nil
    end
  end

  def find_signed!(signed_id, purpose \\ nil) do
    case find_signed(signed_id, purpose) do
      nil ->
        raise "Error find signed record"

      id ->
        id
    end
  end

  def reload!(%{id: id}) do
    ActiveStorage.get_storage_blob!(id)
  end

  # ActiveStorage.Blob.Identifiable

  defdelegate identify(blob), to: ActiveStorage.Blob.Identifiable
  defdelegate identify_without_saving(blob), to: ActiveStorage.Blob.Identifiable
  defdelegate identified?(blob), to: ActiveStorage.Blob.Identifiable
  defdelegate identify_content_type(_blob), to: ActiveStorage.Blob.Identifiable
  defdelegate download_identifiable_chunk(_blob), to: ActiveStorage.Blob.Identifiable

  # ActiveStorage.Blob.Representable

  defdelegate variant(blob, transformations), to: ActiveStorage.Blob.Representable
  defdelegate variable?(blob), to: ActiveStorage.Blob.Representable
  defdelegate preview(blob, transformations), to: ActiveStorage.Blob.Representable
  defdelegate previewable?(blob), to: ActiveStorage.Blob.Representable
  defdelegate representation(blob, transformations), to: ActiveStorage.Blob.Representable
  defdelegate representable?(blob), to: ActiveStorage.Blob.Representable
  defdelegate default_variant_transformations(blob), to: ActiveStorage.Blob.Representable
  defdelegate default_variant_format(blob), to: ActiveStorage.Blob.Representable
  defdelegate format(blob), to: ActiveStorage.Blob.Representable
  defdelegate variant_class(), to: ActiveStorage.Blob.Representable
end
