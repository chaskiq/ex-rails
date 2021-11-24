defmodule ExActiveStorage do
  import Ecto.Query, warn: false
  alias Chaskiq.Repo

  alias ExActiveStorage.StorageBlob

  def graphql_resolver(
        _a,
        %{
          input:
            %{
              byte_size: _byte_size,
              checksum: _checksum,
              content_type: _content_type,
              filename: _filename
            } = input
        },
        %{context: %{current_user: _current_user}}
      ) do
    direct_upload_response = %{direct_upload: create_direct_upload(input)}

    {:ok, direct_upload_response}
  end

  def create_direct_upload(%{
        byte_size: byte_size,
        checksum: checksum,
        content_type: content_type,
        filename: filename
      }) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")
    service = "amazon"

    {:ok, blob} =
      create_storage_blob(%{
        byte_size: byte_size,
        checksum: checksum,
        content_type: content_type,
        filename: filename,
        metadata: %{},
        service_name: service
      })

    # TODO: refactor this to accept local service too

    {:ok, url} = ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, bucket, blob.id)
    signed_blob_id = Chaskiq.Verifier.sign(blob.id)

    headers = Jason.encode!(upload_headers(content_type, blob))

    %{
      url: url,
      service_url: service_url(signed_blob_id),
      headers: headers,
      blob_id: blob.id,
      signed_blob_id: signed_blob_id
    }
  end

  def service_url(signed_blob_id) do
    "/active_storage/blobs/redirect/#{signed_blob_id}"
  end

  def upload_headers(content_type, blob) do
    %{
      "Content-Type": content_type,
      # "Content-MD5": checksum,
      "Content-Disposition":
        "inline; filename=\"#{blob.id}.png\"; filename*=UTF-8''#{blob.id}.png"
    }
  end

  def presigned_url(blob) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket, blob.id)
  end

  # https://www.poeticoding.com/aws-s3-in-elixir-with-exaws/

  # def upload(key, io, %{checksum: nil, filename: nil, content_type: nil, disposition: nil}) do
  def upload(_key, io) do
    stream(io)
  end

  def download(blob) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    ExAws.S3.download_file(
      bucket,
      blob.id,
      "local_file.txt"
    )
    |> ExAws.request!()
  end

  def stream(filename) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    ExAws.S3.Upload.stream_file(filename) |> ExAws.S3.upload(bucket, filename) |> ExAws.request!()
  end
end
