defmodule ActiveStorage.Service.S3Service do
  @behaviour ActiveStorage.Service

  defstruct [
    :public,
    :name,
    :client,
    :bucket,
    :multipart_upload_threshold,
    :upload_options
  ]

  def new(%{client: cli, public: public, bucket: bucket}) do
    %__MODULE__{client: cli, public: public, bucket: bucket}
    # @service = service
  end

  # def new(%{bucket: bucket, upload: upload, public: public}, options \\ []) do
  def new(options \\ []) do
    defaults = [public: false]

    options = Keyword.merge(defaults, options)

    s3_options = map_options = Enum.into(options, %{})
    client = ExAws.Config.new(:s3, s3_options)

    bucket = options |> Keyword.get(:bucket)
    public = options |> Keyword.get(:public)

    # @client = Aws::S3::Resource.new(**options)
    # @bucket = @client.bucket(bucket)

    # @multipart_upload_threshold = upload.delete(:multipart_threshold) || 100.megabytes
    # @public = public

    # @upload_options = upload
    # @upload_options[:acl] = "public-read" if public?
    %__MODULE__{
      client: client,
      bucket: bucket,
      public: public
    }
  end

  @impl ActiveStorage.Service
  def delete(config, blob) do
    bucket = config.bucket

    ExAws.S3.delete_object(bucket, blob.key)
    |> ExAws.request(config.client)
  end

  # ------------------------
  # Need help with the below
  # ------------------------

  def service_name do
    :amazon
  end

  defdelegate open(service, key, options), to: ActiveStorage.Service

  def upload_headers(content_type, blob) do
    %{
      "Content-Type": content_type,
      # "Content-MD5": checksum,
      "Content-Disposition":
        "inline; filename=\"#{blob.id}.png\"; filename*=UTF-8''#{blob.id}.png"
    }
  end

  # def presigned_url(blob) do
  #   bucket = config().bucket

  #   ExAws.S3.presigned_url(config(), :get, bucket, blob.key, expires_in: 300)
  # end

  def config_for_blob(_blob) do
  end

  def aws_config(config) do
    ExAws.Config.new(:s3, config)
  end

  @impl ActiveStorage.Service
  def private_url(service, blob, opts \\ []) do
    bucket = service.bucket

    # object_for(key).presigned_url :get, expires_in: expires_in.to_i,
    #  response_content_disposition: content_disposition_with(type: disposition, filename: filename),
    #  response_content_type: content_type
    ExAws.Config.new(:s3, service.client)
    |> ExAws.S3.presigned_url(:get, bucket, blob.key, opts)
  end

  @impl ActiveStorage.Service
  def public_url(service, key) do
    bucket = service.bucket

    ExAws.Config.new(:s3, service.client)
    |> ExAws.S3.get_object(bucket, key)
  end

  # https://www.poeticoding.com/aws-s3-in-elixir-with-exaws/

  # def upload(key, io, %{checksum: nil, filename: nil, content_type: nil, disposition: nil}) do
  def upload(service, key, io) do
    # stream(io)
    # amazon = Application.fetch_env!(:active_storage, :storage) |> Keyword.get(:amazon)
    # bucket = amazon.bucket
    ActiveStorage.Service.instrument(:upload, %{key: key}, fn ->
      operation =
        ExAws.S3.put_object(
          service.bucket,
          key,
          io
        )

      ExAws.request(operation, service.client)
    end)
  end

  def download(service, key) do
    # ActiveStorage.Service.instrument(:delete_prefixed, %{prefix: prefix}, fn ->

    # if block_given?
    #  instrument :streaming_download, key: key do
    #    stream(key, &block)
    #  end
    # else
    #  instrument :download, key: key do
    #    object_for(key).get.body.string.force_encoding(Encoding::BINARY)
    #  rescue Aws::S3::Errors::NoSuchKey
    #    raise ActiveStorage::FileNotFoundError
    #  end
    # end

    case object_for(service, key) do
      {:ok, %{body: body}} -> {:ok, body}
      _ -> nil
    end
  end

  def stream(filename) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")
    ExAws.S3.Upload.stream_file(filename) |> ExAws.S3.upload(bucket, filename) |> ExAws.request!()
  end

  # def url(blob) do
  #  signed_blob_id = Chaskiq.Verifier.sign(blob.id)
  #  ActiveStorage.service_url(signed_blob_id)
  # end

  # def open(*args, **options, &block) do
  def open(service, blob, args, block) do
    # .open(*args, **options, &block)
    ActiveStorage.Downloader.new(service)
    |> ActiveStorage.Downloader.open(blob, args, block)
  end

  def create_direct_upload(blob, %{
        byte_size: _byte_size,
        checksum: _checksum,
        content_type: content_type,
        filename: _filename
      }) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    # TODO: refactor this to accept local service too

    {:ok, url} = ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, bucket, blob.id)

    headers = Jason.encode!(upload_headers(content_type, blob))

    %{
      url: url,
      service_url: ActiveStorage.service_url(blob),
      headers: headers,
      blob_id: blob.id,
      signed_blob_id: ActiveStorage.verifier().sign(blob.id)
    }
  end

  def exist?(service, key) do
    bucket = service.bucket
    # instrument :exist, key: key do |payload|
    # answer = object_for(key)
    case ExAws.S3.head_object(bucket, key) |> ExAws.request(service.client) do
      {:ok, _} -> true
      {:error, _} -> false
    end

    # .exists?
    # payload[:exist] = answer
    # answer
    # end
  end

  def object_for(service, key) do
    bucket = service.bucket
    ExAws.S3.get_object(bucket, key) |> ExAws.request(service.client)
  end

  def build(%{configurator: _c, name: n, service: _s}, config) do
    new(
      config ++
        [
          bucket: config |> Keyword.get(:bucket),
          # upload: {},
          public: config |> Keyword.get(:public),
          name: n
        ]
    )
  end
end