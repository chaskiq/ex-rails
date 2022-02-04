defmodule ActiveStorage.Downloader do
  # attr_reader :service
  alias __MODULE__
  defstruct [:service]

  def new(service) do
    %__MODULE__{service: service}
    # @service = service
  end

  # def open(key, %{checksum: checksum, verify: verify, name: name, tmpdir: tmpdir}) do
  def open(downloader, key, args, block) do
    service = downloader.service
    a = downloader.service.__struct__.download(service, key)

    dir = System.tmp_dir!()
    tmp_file = Path.join(dir, args.name)
    IO.inspect(tmp_file)

    {:ok, _file} =
      open_tempfile(tmp_file, fn file ->
        verify_integrity_of(a, args)
        IO.binwrite(file, a)
        File.close(file)
      end)

    block.(tmp_file)

    # IO.binwrite(file, a)
    # File.close(file)

    # File.write!(tmp_file)

    # open_tempfile(name, tmpdir) do |file|
    #  download key, file
    #  verify_integrity_of(file, checksum: checksum) if verify
    #  yield file
    # end
  end

  defp open_tempfile(tmp_file, block) do
    # File.open(tmp_file, [:write])
    File.open(tmp_file, [:read, :write], block)

    # file = Tempfile.open(name, tmpdir)

    # begin
    #  yield file
    # ensure
    #  file.close!
    # end
  end

  defp download(_service, _key, _file) do
    # file.binmode
    # service.download(key) { |chunk| file.write(chunk) }
    # file.flush
    # file.rewind
  end

  defp verify_integrity_of(file, %{checksum: checksum}) do
    case :crypto.hash(:md5, file) |> Base.encode64() == checksum do
      true -> true
      false -> raise "ActiveStorage::IntegrityError"
    end

    # unless OpenSSL::Digest::MD5.file(file).base64digest == checksum
    #   raise ActiveStorage::IntegrityError
    # end
  end
end
