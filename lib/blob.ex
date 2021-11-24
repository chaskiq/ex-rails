defmodule ExActiveStorage.StorageBlob do
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :binary_id
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "storage_blob" do
    field(:byte_size, :integer)
    field(:checksum, :string)
    field(:content_type, :string)
    field(:filename, :string)
    # field :key, :string
    field(:metadata, :map)
    field(:service_name, :string)

    timestamps()
  end

  @doc false
  def changeset(storage_blob, attrs) do
    storage_blob
    |> cast(attrs, [
      :filename,
      :content_type,
      :metadata,
      :byte_size,
      :checksum,
      :service_name
    ])
    |> validate_required([
      :filename,
      :content_type,
      :metadata,
      :byte_size,
      :checksum,
      :service_name
    ])
  end
end
