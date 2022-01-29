defmodule StartingTest do
  use ExUnit.Case, async: true

  alias ActiveStorage.Test.{Record, Repo}

  defmodule RailsApp do
    use HTTPoison.Base

    def create_record do
      post("/records", "")
    end

    def add_record_attachment(record_id, attachment_name, path) do
      post(
        "/records/#{record_id}/add_attachment",
        {:multipart, [
          {"attachment_name", attachment_name},
          {:file, path}
        ]}
      )
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

  describe "attachments" do
    # Ruby equivalent: `record.avatar` or `record.favorite_tree_picture`
    test "get_attachment/2 returns the attachment" do
      {:ok, %HTTPoison.Response{body: body}} =
        RailsApp.create_record()

      {:ok, %HTTPoison.Response{body: _}} =
        RailsApp.add_record_attachment(body.id, "avatar", "test/files/test.jpg")

      {:ok, %HTTPoison.Response{body: _}} =
        RailsApp.add_record_attachment(body.id, "favorite_tree_picture", "test/files/tree.png")

      Repo.all(ActiveStorage.Attachment)

      attachment = ActiveStorage.get_attachment!(%Record{id: body.id}, "avatar")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 269595
      assert attachment.blob.checksum == "EaOUdw2PqEjswce87kCVow=="
      assert attachment.blob.filename == "test.jpg"

      attachment = ActiveStorage.get_attachment!(%Record{id: body.id}, "favorite_tree_picture")

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 53758
      assert attachment.blob.checksum == "deD1uRlHDRchMAsRRip+MQ=="
      assert attachment.blob.filename == "tree.png"

    end
  end
end
