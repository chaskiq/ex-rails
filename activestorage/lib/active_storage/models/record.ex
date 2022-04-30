defmodule ActiveStorage.Record do
  use Ecto.Schema
  # import Ecto.Changeset
  import ActiveStorage.{Blob}
  # import ActiveStorage.Blob.Representable
  # import ActiveStorage.Blob.Identifiable
  # import ActiveStorage.Blob.Analyzable

  # @foreign_key_type :binary_id
  schema "active_storage_records" do
    belongs_to(:blob, Blob)
    field(:variation_digest, :string)
  end
end
