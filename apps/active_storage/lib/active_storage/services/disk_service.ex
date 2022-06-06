defmodule ActiveStorage.Service.DiskService do
  defstruct [:root, :public, :name]

  def new(options \\ []) do
    defaults = [root: Temp.path!(), public: false]
    options = Keyword.merge(defaults, options)
    map_options = Enum.into(options, %{})
    %__MODULE__{} |> Map.merge(map_options)
    # @service = service
  end

  defdelegate open(service, key, options), to: ActiveStorage.Service
  # defdelegate url(key, options), to: ActiveStorage.Service

  # Configure an Active Storage service by name from a set of configurations,
  # typically loaded from a YAML file. The Active Storage engine uses this
  # to set the global Active Storage service when the app boots.
  def configure(service_name, configurations) do
    ActiveStorage.Service.Configurator.build(service_name, configurations)
  end

  ### TODO: this should be a behavior

  # Override in subclasses that stitch together multiple services and hence
  # need to build additional services using the configurator.
  #
  # Passes the configurator and all of the service's config as keyword args.
  #
  # See MirrorService for an example.
  # :nodoc:
  def build(%{configurator: _c, name: n, service: _s}, config) do
    root = config |> Keyword.get(:root)
    new(root: root, public: false, name: n)
    # new(service_config)
    # .tap do |service_instance|
    #  service_instance.name = name
    # end
  end

  def upload(service, key, io, options \\ []) do
    default = [checksum: nil]
    options = Keyword.merge(default, options)

    # hack to determine string vs pid,
    # A better way would probably to turn your pid into some opaque value,
    # like: {:file, pid}  and {:stringio, pid} and passing that around

    c =
      case io do
        {:path, io} ->
          {:ok, pid} = File.open(io)

          fn p ->
            IO.binstream(pid, 1_048_576)
            |> Stream.into(File.stream!(p, [:raw, :binary, :write]))
            |> Stream.run()
          end

        {:path_nono, io} ->
          {:ok, pid} = StringIO.open(io)

          fn p ->
            IO.binstream(pid, 1_048_576)
            |> Stream.into(File.stream!(p, [:raw, :binary, :write]))
            |> Stream.run()
          end

        {:string, io} ->
          fn p ->
            File.write(p, io)
          end

        {:io, io} ->
          fn p ->
            :file.position(io, :bof)

            IO.binstream(io, 1_048_576)
            |> Stream.into(File.stream!(p, [:raw, :binary, :write]))
            |> Stream.run()
          end
      end

    ActiveStorage.Service.instrument(:upload, %{key: key}, fn ->
      # instrument :upload, key: key, checksum: checksum do
      # IO.copy_stream(io, make_path_for(key))

      p = make_path_for(service, key)

      case c.(p) do
        :ok ->
          path = __MODULE__.path_for(service, key)

          case options[:checksum] do
            nil ->
              {:ok, p}

            checksum ->
              cond do
                ensure_integrity_of(path, checksum) -> {:ok, p}
                true -> nil
              end
          end

        _ ->
          {:error, "could not upload file from disk service"}
      end
    end)

    # ensure_integrity_of(key, checksum) if checksum
  end

  def download(service, key, block \\ nil) do
    # TODO, implement streaming here, not ram wise
    if block do
      ActiveStorage.Service.instrument(:streaming_download, %{key: key}, fn ->
        stream(service, key, block)
      end)
    else
      ActiveStorage.Service.instrument(:download, %{key: key}, fn ->
        File.read(path_for(service, key))
      end)
    end

    # if block_given?
    #   instrument :streaming_download, key: key do
    #     stream key, &block
    #   end
    # else
    #   instrument :download, key: key do
    #     File.binread path_for(key)
    #   rescue Errno::ENOENT
    #     raise ActiveStorage::FileNotFoundError
    #   end
    # end
  end

  def download_chunk(service, key, _range) do
    # instrument :download_chunk, key: key, range: range do

    ActiveStorage.Service.instrument(:download_chunk, %{key: key}, fn ->
      File.stream!(__MODULE__.path_for(service, key), [], 30096) |> Enum.take(1) |> hd
    end)

    #   File.open(path_for(key), "rb") do |file|
    #     file.seek range.begin
    #     file.read range.size
    #   end
    # rescue Errno::ENOENT
    #   raise ActiveStorage::FileNotFoundError
    # end
  end

  def delete(service, key) do
    ActiveStorage.Service.instrument(:delete, %{key: key}, fn ->
      File.rm(path_for(service, key))
    end)

    # instrument :delete, key: key do
    #   File.delete path_for(key)
    # rescue Errno::ENOENT
    #   # Ignore files already deleted
    # end
  end

  def delete_prefixed(service, prefix) do
    # instrument :delete_prefixed, prefix: prefix do

    ActiveStorage.Service.instrument(:delete_prefixed, %{prefix: prefix}, fn ->
      File.rm_rf(path_for(service, "#{prefix}*"))
    end)

    #   Dir.glob(path_for("#{prefix}*")).each do |path|
    #     FileUtils.rm_rf(path)
    #   end
    # end
  end

  def exist?(service, key) do
    # instrument :exist, key: key do |payload|
    #   answer = File.exist? path_for(key)
    #   payload[:exist] = answer
    #   answer
    # end

    ActiveStorage.Service.instrument(:exists, %{key: key}, fn ->
      File.exists?(path_for(service, key))
    end)
  end

  def url_for_direct_upload(key, options \\ []) do
    ActiveStorage.Service.instrument(:url, %{key: key}, fn ->
      default = [expires_in: nil, content_type: nil, content_length: nil, checksum: nil]
      _options = Keyword.merge(default, options)
    end)

    # instrument :url, key: key do |payload|
    #  verified_token_with_expiration = ActiveStorage.verifier.generate(
    #    {
    #      key: key,
    #      content_type: content_type,
    #      content_length: content_length,
    #      checksum: checksum,
    #      service_name: name
    #    },
    #    expires_in: expires_in,
    #    purpose: :blob_token
    #  )

    #  generated_url = url_helpers.update_rails_disk_service_url(verified_token_with_expiration, host: current_host)

    #  payload[:url] = generated_url

    #  generated_url
    # end
  end

  def headers_for_direct_upload(_key, options \\ []) do
    default = [content_type: nil]
    options = Keyword.merge(default, options)
    %{"Content-Type" => options[:content_type]}
  end

  def stream(service, key, block) do
    File.stream!(path_for(service, key), [], 5_242_880)
    |> Enum.each(fn data ->
      block.(data)
    end)

    #   File.open(path_for(key), "rb") do |file|
    #     while data = file.read(5.megabytes)
    #       yield data
    #     end
    #   end
    # rescue Errno::ENOENT
    #   raise ActiveStorage::FileNotFoundError
  end

  def path_for(service, key) do
    # File.join root, folder_for(key), key
    # |> Path.join(key)
    Path.join(service.root, folder_for(key)) |> Path.join(key)
  end

  def folder_for(key) do
    [String.slice(key, 0, 1), String.slice(key, 2, 3)] |> Enum.join("/")
    # [ key[0..1], key[2..3] ].join("/")
  end

  def make_path_for(service, key) do
    path = path_for(service, key)
    File.mkdir_p!(Path.dirname(path))
    path
    # path_for(key).tap { |path| FileUtils.mkdir_p File.dirname(path) }
  end

  def ensure_integrity_of(path, checksum) do
    case :crypto.hash(:md5, path) |> Base.encode64() == checksum do
      true -> true
      false -> raise ActiveStorage.IntegrityError
    end

    # unless Digest::MD5.file(path_for(key)).base64digest == checksum
    #  delete key
    #  raise ActiveStorage::IntegrityError
    # end
  end

  # Returns the URL for the file at the +key+. This returns a permanent URL for public files, and returns a
  # short-lived URL for private files. For private files you can provide the +disposition+ (+:inline+ or +:attachment+),
  # +filename+, and +content_type+ that you wish the file to be served with on request. Additionally, you can also provide
  # the amount of seconds the URL will be valid for, specified in +expires_in+.
  def url(service, key, options \\ []) do
    # instrument :url, key: key do |payload|
    #  generated_url =
    if ActiveStorage.Service.public?(service) do
      public_url(service, key, options)
    else
      private_url(service, key, options)
    end

    #  payload[:url] = generated_url

    #  generated_url(key)
    # end
  end

  @impl ActiveStorage.Service

  def private_url(_service, key, opts \\ []) do
    defaults = [expires_in: nil, filename: nil, content_type: nil, disposition: nil]
    options = Keyword.merge(defaults, opts)

    case generate_url(key,
           expires_in: options[:expires_in],
           filename: options[:filename],
           content_type: options[:content_type],
           disposition: options[:disposition]
         ) do
      {:ok, url} -> url
      _ -> nil
    end
  end

  @impl ActiveStorage.Service

  def public_url(_service, key, options \\ []) do
    defaults = [
      expires_in: nil,
      filename: options.filename,
      content_type: nil,
      disposition: "attachment"
    ]

    options = Keyword.merge(defaults, options)

    case generate_url(key,
           expires_in: options[:expires_in],
           filename: options[:filename],
           content_type: options[:content_type],
           disposition: options[:disposition]
         ) do
      {:ok, url} -> url
      _ -> nil
    end
  end

  def generate_url(key, options \\ []) do
    defaults = [
      expires_in: nil,
      filename: options[:filename],
      content_type: nil,
      disposition: "inline"
    ]

    options = Keyword.merge(defaults, options)

    # content_disposition = content_disposition_with(type: disposition, filename: filename)
    # verified_key_with_expiration = ActiveStorage.verifier.generate(
    #  {
    #    key: key,
    #    disposition: content_disposition,
    #    content_type: content_type,
    #    service_name: name
    #  },
    #  expires_in: expires_in,
    #  purpose: :blob_key
    # )

    content_disposition =
      ActiveStorage.Service.content_disposition_with(
        disposition: options |> Keyword.get(:disposition),
        filename: options |> Keyword.get(:filename) |> ActiveStorage.Filename.to_s()
      )

    verified_key_with_expiration =
      ActiveStorage.verifier().sign(
        Jason.encode!(%{
          key: key,
          disposition: content_disposition,
          content_type: options |> Keyword.get(:content_type),
          service_name: options |> Keyword.get(:name)
        })
        # ,
        # expires_in: options[:expires_in],
        # purpose: :blob_key
      )

    # if url_options.blank?
    #  raise ArgumentError, "Cannot generate URL for #{filename} using Disk service, please set ActiveStorage::Current.url_options."
    # end

    # url_helpers.rails_disk_service_url(verified_key_with_expiration, filename: filename, **url_options)
    f = options |> Keyword.get(:filename) |> ActiveStorage.Filename.to_s()
    u = "/active_storage/disk/#{verified_key_with_expiration}/#{f}"

    {:ok, u}
  end
end

# rails_disk_service GET      /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
# update_rails_disk_service PUT      /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
# rails_direct_uploads POST     /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create

# <ActiveStorage::Service::DiskService:0x00007fb8d69dece8
# @name=:local,
# @public=false,
# @root="/Users/michelson/Documents/chaskiq/chaskiq/storage">
