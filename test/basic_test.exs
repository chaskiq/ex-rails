defmodule StartingTest do
  use ExUnit.Case, async: true

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
        {:multipart, [
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

  describe "attachments" do
    # For `has_one_attached`
    # Ruby equivalent: `record.avatar` or `record.favorite_tree_picture`
    test "get_attachment/2" do
      {:ok, body} = RailsApp.create_record()

      {:ok, _} = RailsApp.add_record_attachment(body.id, "avatar", "test/files/dog.jpg")

      {:ok, _} = RailsApp.add_record_attachment(body.id, "favorite_tree_picture", "test/files/tree.png")

      attachment = ActiveStorage.get_attachment(%Record{id: body.id}, "avatar")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 269595
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

    # For `has_many_attached`
    # Ruby equivalent: `post.images`
    test "get_attachments/2" do
      {:ok, body} = RailsApp.create_record()
                 |> IO.inspect(label: :record)

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
      assert image.blob.byte_size == 4198124
      assert image.blob.checksum == "ykudRDSZnqMj/cQMEyX3ng=="
      assert image.blob.filename == "oops.tiff"

      image = Enum.at(images, 1)
      assert image.record_type == "Record"
      assert image.blob.byte_size == 269595
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
  end
end
