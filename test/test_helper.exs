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

    {:ok, file} = File.read("./test/files/#{options[:filename]}")
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
    default = [key: nil, filename: "hello.txt", content_type: "text/plain", record: nil]
    options = Keyword.merge(default, options)

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

    {:ok, file} = File.read("./test/files/#{options[:filename]}")
    io = File.read!(file)

    # file = file_fixture(filename)
    # byte_size = file.size
    # checksum = OpenSSL::Digest::MD5.file(file).base64digest
    byte_size = 1234
    checksum = :crypto.hash(:md5, io) |> Base.encode64()

    blob =
      ActiveStorage.Blob.create_blob_before_direct_upload(
        filename: options[:filename],
        byte_size: byte_size,
        checksum: checksum,
        content_type: options[:content_type],
        record: options[:record]
      )

    require IEx
    IEx.pry()

    # create_blob_before_direct_upload(filename: filename, byte_size: byte_size, checksum: checksum, content_type: content_type, record: record).tap do |blob|
    #  service = ActiveStorage::Blob.service.try(:primary) || ActiveStorage::Blob.service
    #  service.upload(blob.key, file.open)
    # end
  end
end

defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
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
