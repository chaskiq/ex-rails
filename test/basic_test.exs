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
    test "list_storage_blob/0 returns all storage_blob" do
      {:ok, %HTTPoison.Response{body: body}} =
        RailsApp.create_record()

      RailsApp.add_record_attachment(body.id, "test/files/test.jpg")
      |> IO.inspect(label: :add_record_attachment)
    end
  end
end
