defmodule ActiveStorage.VariantRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :binary_id
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "storage_variant_record" do
    belongs_to :blob, ActiveStorage.Blob
    # has_one_attached :image
    # has_one :article_settings, ActiveStorage.Blob
    timestamps()
  end

  @doc false
  def changeset(storage_blob, attrs) do
    storage_blob
    |> cast(attrs, [
      :blob_id,
      :variation_digest
    ])
    |> validate_required([
      :blob_id,
      :variation_digest
    ])
  end
end
