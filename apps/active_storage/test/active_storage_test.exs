defmodule ActiveStorageTest do
  use ExUnit.Case, async: false
  # alias Ecto.Adapters.SQL
  alias ActiveStorage.{Blob}
  # import Ecto.Query
  # import Mix.Ecto, only: [build_repo_priv: 1]

  # alias Chaskiq.ActiveStorage
  # doctest ActiveStorage

  setup do
    ActiveStorage.Test.Setup.cleanup_db()
  end

  describe "storage_blob" do
    alias ActiveStorage.Blob

    import ActiveStorageFixtures

    @invalid_attrs %{
      byte_size: nil,
      checksum: nil,
      content_type: nil,
      filename: nil,
      metadata: nil,
      service_name: nil
    }

    test "list_storage_blob/0 returns all storage_blob" do
      storage_blob = storage_blob_fixture()
      result = ActiveStorage.list_storage_blob()
      assert result == [storage_blob]
    end

    test "get_storage_blob!/1 returns the storage_blob with given id" do
      storage_blob = storage_blob_fixture()
      assert ActiveStorage.get_storage_blob!(storage_blob.id) == storage_blob
    end

    test "create_storage_blob/1 with valid data creates a storage_blob" do
      valid_attrs = %{
        byte_size: 42,
        checksum: "some checksum",
        content_type: "some content_type",
        filename: "some filename",
        metadata: "",
        service_name: "some service_name"
      }

      assert storage_blob = storage_blob_fixture(valid_attrs)
      assert storage_blob.byte_size == 42
      assert storage_blob.checksum == "some checksum"
      assert storage_blob.content_type == "some content_type"
      assert storage_blob.filename == "some filename"
      # assert storage_blob.metadata == %{}
      assert storage_blob.service_name == "some service_name"
    end

    test "create_storage_blob/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ActiveStorage.create_storage_blob(@invalid_attrs)
    end

    test "update_storage_blob/2 with valid data updates the storage_blob" do
      storage_blob = storage_blob_fixture()

      update_attrs = %{
        byte_size: 43,
        checksum: "some updated checksum",
        content_type: "some updated content_type",
        filename: "some updated filename",
        metadata: "",
        service_name: "some updated service_name"
      }

      assert {:ok, %Blob{} = storage_blob} =
               ActiveStorage.update_storage_blob(storage_blob, update_attrs)

      assert storage_blob.byte_size == 43
      assert storage_blob.checksum == "some updated checksum"
      assert storage_blob.content_type == "some updated content_type"
      assert storage_blob.filename == "some updated filename"
      # assert storage_blob.metadata == %{}
      assert storage_blob.service_name == "some updated service_name"
    end

    test "update_storage_blob/2 with invalid data returns error changeset" do
      storage_blob = storage_blob_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ActiveStorage.update_storage_blob(storage_blob, @invalid_attrs)

      assert storage_blob == ActiveStorage.get_storage_blob!(storage_blob.id)
    end

    test "delete_storage_blob/1 deletes the storage_blob" do
      storage_blob = storage_blob_fixture()
      assert {:ok, %Blob{}} = ActiveStorage.delete_storage_blob(storage_blob)
      assert_raise Ecto.NoResultsError, fn -> ActiveStorage.get_storage_blob!(storage_blob.id) end
    end

    test "change_storage_blob/1 returns a storage_blob changeset" do
      storage_blob = storage_blob_fixture()
      assert %Ecto.Changeset{} = ActiveStorage.change_storage_blob(storage_blob)
    end
  end
end
