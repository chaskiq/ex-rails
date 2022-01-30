defmodule ActiveStorage.Service.S3 do
  @behaviour ActiveStorage.Service

  @impl ActiveStorage.Service
  def url(config, blob) do
    bucket = config.bucket

    ExAws.S3.presigned_url(aws_config(config), :get, bucket, blob.key, expires_in: 300)
  end

  def delete(config, blob) do
    bucket = config.bucket

    ExAws.S3.delete_object(bucket, blob.key)
    |> ExAws.request(config)
  end

  # ------------------------
  # Need help with the below
  # ------------------------

  def service_name do
    :amazon
  end

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

  defp aws_config(config) do
    ExAws.Config.new(:s3, config)
  end

  # TODO: What is presigned_url vs private_url vs public_url?
  def private_url(blob) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    # object_for(key).presigned_url :get, expires_in: expires_in.to_i,
    #  response_content_disposition: content_disposition_with(type: disposition, filename: filename),
    #  response_content_type: content_type
    case ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:get, bucket, blob.id) do
      {:ok, url} -> url
      _ -> nil
    end
  end

  def public_url(key) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    # object_for(key).public_url
    case ExAws.Config.new(:s3)
         |> ExAws.S3.get_object(bucket, key) do
      {:ok, url} -> url
      _ -> nil
    end
  end

  # https://www.poeticoding.com/aws-s3-in-elixir-with-exaws/

  # def upload(key, io, %{checksum: nil, filename: nil, content_type: nil, disposition: nil}) do
  def upload(blob, io) do
    # stream(io)
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    operation =
      ExAws.S3.put_object(
        bucket,
        blob.id,
        io
      )

    ExAws.request(operation)
  end

  def download(key) do
    _bucket = System.fetch_env!("AWS_S3_BUCKET")

    case object_for(key) do
      {:ok, %{body: body}} -> body
      _ -> nil
    end

    # ExAws.S3.download_file(
    #  bucket,
    #  key,
    #  "local_file.txt"
    # )
    # |> ExAws.request!()
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
  def open(blob, args, block) do
    # .open(*args, **options, &block)
    ActiveStorage.Downloader.new(__MODULE__)
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
      signed_blob_id: Chaskiq.Verifier.sign(blob.id)
    }
  end

  def exist?(key) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")
    # instrument :exist, key: key do |payload|
    # answer = object_for(key)
    case ExAws.S3.head_object(bucket, key) |> ExAws.request() do
      {:ok, _} -> true
      {:error, _} -> false
    end

    # .exists?
    # payload[:exist] = answer
    # answer
    # end
  end

  def object_for(key) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    ExAws.S3.get_object(bucket, key) |> ExAws.request()
  end
end

# #<ActiveStorage::Service::S3Service:0x00007fb8c88a6078
# @bucket=
#   #<Aws::S3::Bucket:0x00007fb8c888ee50
#    @arn=nil,
#    @client=#<Aws::S3::Client>,
#    @data=nil,
#    @name="hermessapp",
#    @resolved_region="us-east-1",
#    @waiter_block_warned=false>,
#  @client=#<Aws::S3::Resource:0x00007fb8c88a5fd8 @client=#<Aws::S3::Client>>,
#  @multipart_upload_threshold=104857600,
#  @name=:amazon,
#  @public=false,
#  @upload_options={}>
