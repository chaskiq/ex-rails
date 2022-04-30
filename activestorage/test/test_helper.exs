# Mix.Task.run("ecto.create", ~w(-r ActiveStorage.Test.Repo))
# Mix.Task.run("ecto.migrate", ~w(-r ActiveStorage.Test.Repo))

# ActiveStorage.Test.Repo.start_link()

ExUnit.start(timeout: 100_000_000)

alias ActiveStorage.Test.Repo

# {:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(Repo, :temporary)

# _ = Ecto.Adapters.Postgres.storage_down(Repo.config())
# :ok = Ecto.Adapters.Postgres.storage_up(Repo.config())

{:ok, _pid} = Repo.start_link()

# Code.require_file("ecto_migration.exs", __DIR__)

# :ok = Ecto.Migrator.up(Repo, 0, Ecto.Integration.Migration)
# Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
# Process.flag(:trap_exit, true)

defmodule ActiveStorageTestHelpers do
  def create_blob(options \\ []) do
    default = [
      key: nil,
      data: "Hello world!",
      filename: "hello.txt",
      content_type: "text/plain",
      identify: true,
      # nil,
      service_name: "local",
      record: nil,
      identify: true
    ]

    options = Keyword.merge(default, options)

    ActiveStorage.Blob.create_and_upload!(%ActiveStorage.Blob{},
      key: options[:key],
      io: options[:data],
      filename: options[:filename],
      content_type: options[:content_type],
      metadata: options[:metadata],
      service_name: options[:service_name],
      identify: options[:identify]
    )

    # ActiveStorage::Blob.create_and_upload! key: key, io: StringIO.new(data), filename: filename, content_type: content_type, identify: identify, service_name: service_name, record: record
  end

  def create_file_blob(options \\ []) do
    default = [
      key: nil,
      filename: "racecar.jpg",
      content_type: "image/jpeg",
      metadata: nil,
      service_name: "local",
      record: nil
    ]

    options = Keyword.merge(default, options)

    file =
      case File.read("./test/files/#{options[:filename]}") do
        {:ok, file} -> file
        _ -> nil
      end

    # filename = "dog.jpg"
    # {mime, _w, _h, _kind} = ExImageInfo.info(file)

    blob = %ActiveStorage.Blob{}

    ActiveStorage.Blob.create_and_upload!(blob,
      io: file,
      filename: options[:filename],
      content_type: options[:content_type],
      metadata: options[:metadata],
      service_name: options[:service_name],
      identify: true
    )

    # ActiveStorage::Blob.create_and_upload! io: file_fixture(filename).open, filename: filename, content_type: content_type, metadata: metadata, service_name: service_name, record: record
  end

  def create_blob_before_direct_upload(options \\ []) do
    default = [
      key: nil,
      filename: "hello.txt",
      content_type: "text/plain",
      record: nil,
      block: nil
    ]

    options = Keyword.merge(default, options)

    ActiveStorage.Blob.create_before_direct_upload!(options)

    # ActiveStorage::Blob.create_before_direct_upload! key: key, filename: filename, byte_size: byte_size, checksum: checksum, content_type: content_type, record: record
  end

  def build_blob_after_unfurling(options \\ []) do
    default = [
      key: nil,
      data: "Hello world!",
      filename: "hello.txt",
      content_type: "text/plain",
      identify: true,
      record: nil
    ]

    options = Keyword.merge(default, options)

    ActiveStorage.Blob.build_after_unfurling(%ActiveStorage.Blob{},
      key: options[:key],
      io: options[:data],
      filename: options[:filename],
      content_type: options[:content_type],
      identify: options[:identify],
      record: options[:record]
    )

    # ActiveStorage::Blob.build_after_unfurling key: key, io: StringIO.new(data), filename: filename, content_type: content_type, identify: identify, record: record
  end

  def directly_upload_file_blob(options \\ []) do
    default = [filename: "racecar.jpg", content_type: "image/jpeg", record: nil]
    options = Keyword.merge(default, options)

    {:ok, io} = File.read("./test/files/#{options[:filename]}")

    # file = file_fixture(filename)
    # byte_size = file.size
    # checksum = OpenSSL::Digest::MD5.file(file).base64digest
    byte_size = ActiveStorage.Blob.get_byte_size(io)
    checksum = ActiveStorage.Blob.compute_checksum_in_chunks(io)

    blob =
      create_blob_before_direct_upload(
        filename: options[:filename],
        byte_size: byte_size,
        checksum: checksum,
        content_type: options[:content_type],
        record: options[:record]
      )

    service = ActiveStorage.Blob.service(blob)
    service.__struct__.upload(service, blob.key, io)

    blob

    # create_blob_before_direct_upload(filename: filename, byte_size: byte_size, checksum: checksum, content_type: content_type, record: record).tap do |blob|
    #  service = ActiveStorage::Blob.service.try(:primary) || ActiveStorage::Blob.service
    #  service.upload(blob.key, file.open)
    # end
  end

  def read_image(blob_or_variant = %ActiveStorage.Variant{}) do
    srv = blob_or_variant.blob |> ActiveStorage.Blob.service()
    key = ActiveStorage.Variant.key(blob_or_variant)
    Mogrify.open(srv.__struct__.path_for(srv, key)) |> Mogrify.verbose()
  end

  def read_image(blob_or_variant) do
    srv = blob_or_variant |> ActiveStorage.Blob.service()
    Mogrify.open(srv.__struct__.path_for(srv, blob_or_variant.key)) |> Mogrify.verbose()
  end

  def image_format(blob_or_variant = %ActiveStorage.Variant{}, format \\ "'%[m]'") do
    srv = blob_or_variant.blob |> ActiveStorage.Blob.service()
    key = ActiveStorage.Variant.key(blob_or_variant)
    p = srv.__struct__.path_for(srv, key)
    Mogrify.identify(p, format: format)
  end

  def read_image(blob_or_variant) do
    # MiniMagick :: Image.open(blob_or_variant.service.send(:path_for, blob_or_variant.key))
  end

  def extract_metadata_from(blob) do
    # IO.inspect(ActiveStorage.Blob.analyze(blob))
    ActiveStorage.Blob.analyze(blob).metadata
  end
end

defmodule Size do
  # taken from: https://github.com/jfcalvo/size/blob/master/lib/size.ex
  @spec megabytes(number) :: integer
  defmacro megabytes(megabytes) when is_float(megabytes) do
    round(Float.ceil(megabytes * 1024 * 1024))
  end

  defmacro megabytes(megabytes) when is_integer(megabytes) do
    megabytes * 1024 * 1024
  end

  @spec kilobytes(number) :: integer
  defmacro kilobytes(kilobytes) when is_float(kilobytes) do
    round(Float.ceil(kilobytes * 1024))
  end

  defmacro kilobytes(kilobytes) when is_integer(kilobytes) do
    kilobytes * 1024
  end
end

defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  use ActiveStorage.Attached.Model
  use ActiveStorage.Attached.HasOne, name: :avatar, model: "User"
  use ActiveStorage.Attached.HasMany, name: :highlights, model: "User"

  schema "users" do
    field(:name, :string)

    has_one(:avatar_attachment, ActiveStorage.Attachment,
      where: [record_type: "User"],
      foreign_key: :record_id
    )

    has_one(:avatar_blob, through: [:avatar_attachment, :blob])

    has_many(:highlights_attachments, ActiveStorage.Attachment,
      where: [record_type: "User"],
      foreign_key: :record_id
    )

    has_many(:highlights_blobs, through: [:highlights_attachments, :blob])
  end

  def record_type() do
    "User"
  end

  def create!(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> unique_constraint(:name)
    |> Repo.insert!()
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [
      :name
    ])
    |> validate_required([
      :name
    ])
  end
end
