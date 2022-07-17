defmodule ActiveStorage.Downloader do
  # attr_reader :service
  alias __MODULE__
  defstruct [:service]

  def new(service) do
    %__MODULE__{service: service}
    # @service = service
  end

  # def open(key, %{checksum: checksum, verify: verify, name: name, tmpdir: tmpdir}) do
  def open(downloader, key, options \\ []) do
    defaults = [checksum: nil, name: "ActiveStorage-", tmpdir: nil, block: nil]
    options = Keyword.merge(defaults, options)

    service = downloader.service

    open_tempfile(options[:name], options[:tmpdir], fn file ->
      {:ok, file_contents} = download(service, key, file)

      # a = IO.read(file, :line)
      # https://pspdfkit.com/blog/2021/the-perils-of-large-files-in-elixir/
      # article on how to handle large files.

      verify_integrity_of({:string, file_contents}, checksum: options[:checksum])

      {:ok, tmp_file} = File.open(file, [:write])
      IO.binwrite(tmp_file, file_contents)
      File.close(tmp_file)

      if(options[:block]) do
        options[:block].(file)
      else
        file
      end
    end)
  end

  # not using this
  def open_disabled(downloader, key, args, block) do
    service = downloader.service

    case downloader.service.__struct__.download(service, key) do
      {:ok, a} ->
        dir = System.tmp_dir!()

        {:ok, file} =
          open_tempfile(args.name, dir, fn file ->
            verify_integrity_of(a, args)
            IO.binwrite(file, a)
            File.close(file)
          end)

        if(block) do
          block.(file)
        else
          file
        end

      {:error, _} ->
        {:error, nil}
    end

    # IO.binwrite(file, a)
    # File.close(file)

    # File.write!(tmp_file)

    # open_tempfile(name, tmpdir) do |file|
    #  download key, file
    #  verify_integrity_of(file, checksum: checksum) if verify
    #  yield file
    # end
  end

  defp open_tempfile(name, tmp_dir, block) do
    [prefix, suffix] = name

    path_options =
      case tmp_dir do
        nil -> %{prefix: prefix, suffix: suffix}
        base_dir -> %{prefix: prefix, suffix: suffix, base_dir: base_dir}
      end

    case Temp.path(path_options) do
      {:ok, tmp_path} ->
        block.(tmp_path)

      _ ->
        nil
    end

    # file = Tempfile.open(name, tmpdir)

    # begin
    #  yield file
    # ensure
    #  file.close!
    # end
  end

  defp download(service, key, _file) do
    {:ok, _downloaded_file} = service.__struct__.download(service, key)

    # IO.binwrite(file, downloaded_file)
    # file.binmode
    # service.download(key) { |chunk| file.write(chunk) }
    # file.flush
    # file.rewind
  end

  defp verify_integrity_of(file, checksum: checksum) do
    # 8MB
    # line_or_bytes = 8_000_000
    # stream = File.stream!(file, [], line_or_bytes)
    # initial_digest = :crypto.hash_init(:md5)
    #
    # digest =
    #  stream
    #  |> Enum.reduce(initial_digest, fn chunk, digest ->
    #    :crypto.hash_update(digest, chunk)
    #  end)
    #  |> :crypto.hash_final()
    #  |> Base.encode64(case: :lower, padding: false)
    #
    # case digest == checksum do
    #  true -> true
    #  false -> raise "ActiveStorage::IntegrityError"
    # end

    case ActiveStorage.Blob.compute_checksum_in_chunks(file) == checksum do
      true -> true
      false -> raise ActiveStorage.IntegrityError
    end

    # unless OpenSSL::Digest::MD5.file(file).base64digest == checksum
    #  raise ActiveStorage::IntegrityError
    # end
  end
end
