defmodule ActiveStorage.Blob do
  use Ecto.Schema
  import Ecto.Changeset
  import ActiveStorage.{RepoClient}
  # import ActiveStorage.Blob.Representable
  # import ActiveStorage.Blob.Identifiable
  # import ActiveStorage.Blob.Analyzable

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

    timestamps(inserted_at: :created_at, updated_at: false)
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
    |> prepare_changes(&set_defaults/1)
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
    # self.team_schedule = []

    current_changeset
    # if encryption_key.blank?
    |> generate_encryption_key()
  end

  def generate_encryption_key(current_changeset) do
    binary = Ecto.UUID.bingenerate()
    {:ok, k} = Ecto.UUID.load(binary)

    case current_changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(current_changeset, :key, k)

      _ ->
        current_changeset
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

  def build_after_unfurling(blob, %{
        # key: k,
        io: io,
        filename: filename,
        content_type: content_type,
        metadata: metadata,
        service_name: service_name,
        identify: identify
        # record: record
      }) do
    n =
      blob
      |> ActiveStorage.Blob.changeset(%{
        # byte_size: byte_size,
        # checksum: checksum,
        content_type: content_type,
        filename: filename,
        # :key:   key,
        metadata: metadata,
        service_name: service_name
      })

    case n do
      %Ecto.Changeset{valid?: true} ->
        n |> unfurl(io, %{identify: identify})

      %Ecto.Changeset{valid?: false} ->
        n
    end

    # new(key: key, filename: filename, content_type: content_type, metadata: metadata, service_name: service_name).tap do |blob|
    #  blob.unfurl(io, identify: identify)
    # end
  end

  def create_after_unfurling!(blob, %{
        # key: k,
        io: io,
        filename: filename,
        content_type: content_type,
        metadata: metadata,
        service_name: service_name,
        identify: identify
        # record: record
      }) do
    build_after_unfurling(blob, %{
      # key: k,
      io: io,
      filename: filename,
      content_type: content_type,
      metadata: metadata,
      service_name: service_name,
      identify: identify
    })
    |> repo().insert!()

    # changeset.tap(&:save!)
  end

  # Creates a new blob instance and then uploads the contents of
  # the given <tt>io</tt> to the service. The blob instance is going to
  # be saved before the upload begins to prevent the upload clobbering another due to key collisions.
  # When providing a content type, pass <tt>identify: false</tt> to bypass
  # automatic content type inference.
  def create_and_upload!(blob, %{
        # key: k,
        io: io,
        filename: filename,
        content_type: content_type,
        metadata: metadata,
        service_name: service_name,
        identify: identify
        # record: record
      }) do
    blob =
      create_after_unfurling!(blob, %{
        io: io,
        filename: filename,
        content_type: content_type,
        metadata: metadata,
        service_name: service_name,
        identify: identify
      })

    blob |> upload_without_unfurling(io)

    # create_after_unfurling!(%{key: key, io: io, filename: filename, content_type: content_type, metadata: metadata, service_name: service_name, identify: identify}) .tap do |blob|
    #  blob.upload_without_unfurling(io)
    # end
  end

  # Returns a saved blob _without_ uploading a file to the service. This blob will point to a key where there is
  # no file yet. It's intended to be used together with a client-side upload, which will first create the blob
  # in order to produce the signed URL for uploading. This signed URL points to the key generated by the blob.
  # Once the form using the direct upload is submitted, the blob can be associated with the right record using
  # the signed ID.
  def create_before_direct_upload!(_blob, %{
        key: _k,
        io: _io,
        filename: _filename,
        content_type: _content_type,
        metadata: _metadata,
        service_name: _service_name,
        identify: _identify,
        record: _record
      }) do
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
  def upload(blob, io, %{identify: true} = identify) do
    blob
    |> unfurl(io, identify)
    |> upload_without_unfurling(io)
  end

  # Deletes the files on the service associated with the blob. This should only be done if the blob is going to be
  # deleted as well or you will essentially have a dead reference. It's recommended to use #purge and #purge_later
  # methods in most circumstances.
  def delete(_blob) do
    # service.delete(key)
    # service.delete_prefixed("variants/#{key}/") if image?
  end

  # Destroys the blob record and then deletes the file on the service. This is the recommended way to dispose of unwanted
  # blobs. Note, though, that deleting the file off the service will initiate an HTTP connection to the service, which may
  # be slow or prevented, so you should not use this method inside a transaction or in callbacks. Use #purge_later instead.
  def purge(_blob) do
    # destroy
    # delete if previously_persisted?
    # rescue ActiveRecord::InvalidForeignKey
  end

  # Enqueues an ActiveStorage::PurgeJob to call #purge. This is the recommended way to purge blobs from a transaction,
  # an Active Record callback, or in any other real-time scenario.
  def purge_later do
    # ActiveStorage::PurgeJob.perform_later(self)
  end

  def service(blob) do
    # Application.get_env(:active_storage, :storage)
    # |> Keyword.get(blob.service_name |> String.to_existing_atom())
    ActiveStorage.Service.Registry.fetch(blob.service_name)
    # services.fetch(blob.service_name)
  end

  # :nodoc:
  def unfurl(blob, io, _identify) do
    checksum = compute_checksum_in_chunks(blob, io)
    # ExImageInfo.seems?(io)
    <<head::size(8), _rest::binary>> = io
    bite_size = head

    data = %{
      byte_size: bite_size,
      metadata: Jason.encode!(%{identified: true}),
      checksum: checksum
    }

    data =
      if blob.changes |> Map.has_key?(:content_type) != true do
        {mime, _w, _h, _} = ExImageInfo.info(io)
        content_type = mime
        data |> Map.merge(%{content_type: content_type})
      else
        data
      end

    blob
    |> Ecto.Changeset.change(data)

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

    case mod.upload(srv, blob, io) do
      {:ok, _response} ->
        blob

      {:error, err} ->
        require IEx
        IEx.pry()
        nil
    end

    # srv.upload(blob, "./README.md")
    # service.upload key, io, checksum: checksum, **service_metadata
  end

  def compute_checksum_in_chunks(_blob, io) do
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
  # def filename
  #  ActiveStorage::Filename.new(self[:filename])
  # end

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
  def open(blob, block) do
    ext = MIME.extensions(MIME.from_path(blob.filename)) |> hd
    name = ["ActiveStorage-#{blob.id}-", ".#{ext}"]
    service = service(blob)
    service.__struct__.open(service, blob.key, %{checksum: blob.checksum, name: name}, block)
    # service.open blob.key, checksum: blob.checksum,
    #  name: [ "ActiveStorage-#{id}-", blob.filename.extension_with_delimiter ], tmpdir: tmpdir, &block
  end

  def extract_content_type(_io) do
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
end