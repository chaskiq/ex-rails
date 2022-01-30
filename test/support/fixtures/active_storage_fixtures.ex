defmodule ActiveStorageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chaskiq.ActiveStorage` context.
  """

  @doc """
  Generate a storage_blob.
  """
  def storage_blob_fixture(attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        byte_size: 42,
        checksum: "some checksum",
        content_type: "some content_type",
        filename: "some filename",
        metadata: "",
        service_name: "some service_name"
      })

    {:ok, record} = params |> ActiveStorage.create_storage_blob()

    record
  end
end
