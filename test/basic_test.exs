defmodule StartingTest do
  use ExUnit.Case, async: true

  defmodule RailsApp do
    use HTTPoison.Base

    def create_record do
      post("/records", "")
    end

    def add_record_attachment(record_id, path) do
      post("/records/#{record_id}/add_attachment", {:multipart, [{:file, path}]})
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

  describe "uploading a file" do
    test "get_attachment/2 returns the attachment" do
      {:ok, %HTTPoison.Response{body: body}} =
        RailsApp.create_record()

      {:ok, %HTTPoison.Response{body: body}} =
        RailsApp.add_record_attachment(body.id, "test/files/test.jpg")

      ExActiveStorage.Repo.all(ActiveStorage.Attachment)

      attachment = ActiveStorage.get_attachment!("Record", body.id)
                   |> IO.inspect()

      assert attachment.record_type == "Record"
      assert attachment.blob.byte_size == 269595
      assert attachment.blob.checksum == "EaOUdw2PqEjswce87kCVow=="
      assert attachment.blob.filename == "test.jpg"

    end
  end
end
