defmodule StartingTest do
  use ExUnit.Case, async: false

  alias ActiveStorage.Test.{Record, Repo}

  defmodule RailsApp do
    use HTTPoison.Base

    def create_record do
      post("/records", "")
      |> return_body()
    end

    def add_record_attachment(record_id, attachment_name, path) do
      post(
        "/records/#{record_id}/add_attachment",
        {:multipart,
         [
           {"attachment_name", attachment_name},
           {:file, path}
         ]}
      )
      |> return_body()
    end

    defp return_body(result) do
      case result do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
        other -> other
      end
    end

    # Overwritten functions

    def process_request_url(path) do
      "http://localhost:3000" <> path
    end

    def process_response_body(body) do
      body
      |> Jason.decode!(keys: :atoms)
    end
  end

  # TODO: Cleanup table before each test

  setup do
    ExAws.S3.put_bucket("active-storage-test", "us-east-1")
    |> ExAws.request(
      access_key_id: "root",
      secret_access_key: "active_storage_test",
      scheme: "http://",
      host: "localhost",
      port: 9000,
      force_path_style: true
    )
    |> case do
      {:error, {:http_error, 409, _}} ->
        # Bucket already exists, not a problem

        nil

      other ->
        other
    end

    ActiveStorage.Test.Setup.cleanup_db()
  end

  describe "attachments" do
    # For `has_one_attached`
    # Ruby equivalent: `record.avatar` or `record.favorite_tree_picture`
    test "get_attachment/2 - Local" do
      {:ok, body} = RailsApp.create_record()

      {:ok, _} = RailsApp.add_record_attachment(body.id, "avatar", "test/files/dog.jpg")

      {:ok, _} =
        RailsApp.add_record_attachment(body.id, "favorite_tree_picture", "test/files/tree.png")

      attachment = ActiveStorage.get_attachment(%Record{id: body.id}, "avatar")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 269_595
      assert attachment.blob.checksum == "EaOUdw2PqEjswce87kCVow=="
      assert attachment.blob.filename == "dog.jpg"

      attachment = ActiveStorage.get_attachment(%Record{id: body.id}, "favorite_tree_picture")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 53758
      assert attachment.blob.checksum == "deD1uRlHDRchMAsRRip+MQ=="
      assert attachment.blob.filename == "tree.png"

      attachment = ActiveStorage.get_attachment(%Record{id: body.id}, "undefined_attachment")
      assert attachment == nil

      attachment = ActiveStorage.get_attachment(%Record{id: 999_999_999}, "undefined_attachment")
      assert attachment == nil
    end

    test "get_attachment/2 - Minio" do
      {:ok, body} = RailsApp.create_record()

      {:ok, attachment_result_body} =
        RailsApp.add_record_attachment(body.id, "minio_avatar", "test/files/dog.jpg")

      attachment = ActiveStorage.get_attachment(%Record{id: body.id}, "minio_avatar")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 269_595
      assert attachment.blob.checksum == "EaOUdw2PqEjswce87kCVow=="
      assert attachment.blob.filename == "dog.jpg"

      # TODO: Put `url_for_attachment` in it's own test block
      url = ActiveStorage.url_for_attachment(attachment, expires_in: 300)
      uri = URI.parse(url)
      query = URI.decode_query(uri.query)

      ruby_uri = URI.parse(attachment_result_body.url)
      ruby_query = URI.decode_query(ruby_uri.query)

      # Not testing hostname.  Ruby sees it as `minio`, Elixir sees it as `localhost`
      assert uri.port == 9000
      assert uri.path == ruby_uri.path

      assert query["X-Amz-Algorithm"] == ruby_query["X-Amz-Algorithm"]
      assert query["X-Amz-Credential"] == ruby_query["X-Amz-Credential"]

      # assert query["X-Amz-Date"] == ruby_query["X-Amz-Date"] # Can be off by a second, didn't want to bother parsing
      assert query["X-Amz-Expires"] == ruby_query["X-Amz-Expires"]
      assert query["X-Amz-SignedHeaders"] == ruby_query["X-Amz-SignedHeaders"]

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)
      assert body == File.read!("test/files/dog.jpg")
    end

    # For `has_many_attached`
    # Ruby equivalent: `post.images`
    test "get_attachments/2" do
      {:ok, body} = RailsApp.create_record()

      images = ActiveStorage.get_attachments(%Record{id: body.id}, "images")
      assert images == []

      {:ok, _} = RailsApp.add_record_attachment(body.id, "images", "test/files/oops.tiff")

      images = ActiveStorage.get_attachments(%Record{id: body.id}, "images")
      assert length(images) == 1

      {:ok, _} = RailsApp.add_record_attachment(body.id, "images", "test/files/dog.jpg")

      images = ActiveStorage.get_attachments(%Record{id: body.id}, "images")
      assert length(images) == 2

      image = Enum.at(images, 0)
      assert image.record_type == "Record"
      assert image.blob.byte_size == 4_198_124
      assert image.blob.checksum == "ykudRDSZnqMj/cQMEyX3ng=="
      assert image.blob.filename == "oops.tiff"

      image = Enum.at(images, 1)
      assert image.record_type == "Record"
      assert image.blob.byte_size == 269_595
      assert image.blob.checksum == "EaOUdw2PqEjswce87kCVow=="
      assert image.blob.filename == "dog.jpg"
    end

    # Ruby equivalent: `record.avatar.attached?`
    test "attached?/2" do
      {:ok, body} = RailsApp.create_record()

      {:ok, _} = RailsApp.add_record_attachment(body.id, "avatar", "test/files/dog.jpg")

      assert ActiveStorage.attached?(%Record{id: body.id}, "avatar") == true
      assert ActiveStorage.attached?(%Record{id: 999_999_999}, "avatar") == false
    end

    # Ruby equivalent: `user.minio_avatar.purge`
    test "purge_attachment/2 - Minio" do
      {:ok, body} = RailsApp.create_record()

      {:ok, _} = RailsApp.add_record_attachment(body.id, "minio_avatar", "test/files/dog.jpg")

      avatar_original = ActiveStorage.get_attachment(%Record{id: body.id}, "minio_avatar")

      url = ActiveStorage.url_for_attachment(avatar_original)

      attachment = ActiveStorage.purge_attachment(%Record{id: body.id}, "minio_avatar")

      avatar = ActiveStorage.get_attachment(%Record{id: body.id}, "minio_avatar")

      assert avatar == nil

      assert Repo.get(ActiveStorage.Blob, avatar_original.blob.id) == nil

      {:ok, response} = HTTPoison.get(url)
      assert response.status_code == 404

      # Test that it's all run inside transaction (Mox S3 delete to fail, if possible)
      # TODO: Test that transaction works (??)
    end

    test "user test" do
      User.insert(%User{}, %{a: 1})
    end
  end
end
