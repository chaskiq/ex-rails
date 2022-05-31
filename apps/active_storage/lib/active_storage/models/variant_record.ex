defmodule ActiveStorage.VariantRecord do
  use Ecto.Schema
  import Ecto.Changeset

  use ActiveStorage.Attached.Model
  use ActiveStorage.Attached.HasOne, name: :image

  # @foreign_key_type :binary_id
  schema "active_storage_variant_records" do
    belongs_to(:blob, ActiveStorage.Blob)

    # has_one_attached :image
    has_one(:image_attachment, ActiveStorage.Attachment,
      where: [record_type: "ActiveStorage.VariantRecord"],
      foreign_key: :record_id
    )

    has_one(:image_blob, through: [:image_attachment, :blob])
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
