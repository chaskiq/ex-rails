defmodule ActiveStorage.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  alias ActiveStorage.Blob

  schema "active_storage_attachments" do
    field(:name, :string, null: false)
    field(:record_type, :string, null: false)
    field(:record_id, :integer, null: false)

    belongs_to(:blob, Blob)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [
      :name,
      :record_type,
      :record_id,
      :created_at
    ])
    |> cast_assoc(:blob)
    |> validate_required([
      :name,
      :record_type,
      :record_id,
      :created_at
    ])
    |> assoc_constraint(:blob)
  end

  def new(record: record, name: name, blob: blob) do
    %__MODULE__{
      record_id: record.id,
      record_type: record.__struct__ |> to_string,
      blob_id: blob.id,
      name: name
    }
  end
end
