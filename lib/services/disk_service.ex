defmodule ActiveStorage.Service.DiskService do
  defstruct [:root, :public, :name]

  def new(%{root: root, public: public}, options \\ []) do
    defaults = []
    options = Keyword.merge(defaults, options)
    %__MODULE__{root: root, public: public}
    # @service = service
  end

  defdelegate open(service, key, options), to: ActiveStorage.Service

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
  def build(%{configurator: _c, name: n, service: s}, config) do
    new(%{root: config.root, public: true}) |> Map.put(:name, n)
    # new(service_config)
    # .tap do |service_instance|
    #  service_instance.name = name
    # end
  end

  def upload(service, key, io, options \\ []) do
    default = [checksum: nil]
    options = Keyword.merge(default, options)
    # instrument :upload, key: key, checksum: checksum do
    # IO.copy_stream(io, make_path_for(key))
    p = make_path_for(service, key.key)
    # IO.inspect(p)

    case File.write(p, io) do
      :ok ->
        # ensure_integrity_of(key, checksum) if checksum
        {:ok, p}

      _ ->
        {:error, "could not upload file from disk service"}
    end

    # ensure_integrity_of(key, checksum) if checksum
  end

  def download(service, key, _block \\ nil) do
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

    # TODO, implement streaming here, not ram wise
    File.read(path_for(service, key))
  end

  def download_chunk(key, range) do
    # instrument :download_chunk, key: key, range: range do
    #   File.open(path_for(key), "rb") do |file|
    #     file.seek range.begin
    #     file.read range.size
    #   end
    # rescue Errno::ENOENT
    #   raise ActiveStorage::FileNotFoundError
    # end
  end

  def delete(service, key) do
    # instrument :delete, key: key do
    #   File.delete path_for(key)
    File.rm(path_for(service, key))
    # rescue Errno::ENOENT
    #   # Ignore files already deleted
    # end
  end

  def delete_prefixed(service, prefix) do
    # instrument :delete_prefixed, prefix: prefix do
    File.rm_rf(path_for(service, "#{prefix}*"))
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
    File.exists?(path_for(service, key))
  end

  def url_for_direct_upload(key, options \\ []) do
    default = [expires_in: nil, content_type: nil, content_length: nil, checksum: nil]
    options = Keyword.merge(default, options)

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

  def headers_for_direct_upload(key, options \\ []) do
    default = [content_type: nil]
    options = Keyword.merge(default, options)
    %{"Content-Type" => options[:content_type]}
  end

  def path_for(service, key) do
    # File.join root, folder_for(key), key
    Path.join(service.root, folder_for(key)) |> Path.join(key)
  end

  def folder_for(key) do
    key
    # [ key[0..1], key[2..3] ].join("/")
  end

  def make_path_for(service, key) do
    path = path_for(service, key)
    File.mkdir_p!(Path.dirname(path))
    path
    # path_for(key).tap { |path| FileUtils.mkdir_p File.dirname(path) }
  end

  def ensure_integrity_of(key, checksum) do
    # unless Digest::MD5.file(path_for(key)).base64digest == checksum
    #  delete key
    #  raise ActiveStorage::IntegrityError
    # end
  end

  @impl ActiveStorage.Service

  def private_url(service, key, opts \\ []) do
    defaults = [expires_in: nil, filename: nil, content_type: nil, disposition: nil]
    options = Keyword.merge(defaults, opts)

    generate_url(key,
      expires_in: options[:expires_in],
      filename: options[:filename],
      content_type: options[:content_type],
      disposition: options[:disposition]
    )
  end

  @impl ActiveStorage.Service

  def public_url(service, key, options \\ []) do
    defaults = [expires_in: nil, filename: nil, content_type: nil, disposition: nil]
    options = Keyword.merge(defaults, options)

    generate_url(key,
      expires_in: options[:expires_in],
      filename: options[:filename],
      content_type: options[:content_type],
      disposition: options[:disposition]
    )
  end

  def generate_url(key, options \\ []) do
    defaults = [expires_in: nil, filename: nil, content_type: nil, disposition: nil]
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

    # if url_options.blank?
    #  raise ArgumentError, "Cannot generate URL for #{filename} using Disk service, please set ActiveStorage::Current.url_options."
    # end

    # url_helpers.rails_disk_service_url(verified_key_with_expiration, filename: filename, **url_options)
    {:ok, "GENERATED_URL_HERE -- changeme in disk_service.ex"}
  end
end

# <ActiveStorage::Service::DiskService:0x00007fb8d69dece8
# @name=:local,
# @public=false,
# @root="/Users/michelson/Documents/chaskiq/chaskiq/storage">
