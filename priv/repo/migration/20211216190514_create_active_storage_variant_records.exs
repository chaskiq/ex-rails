defmodule Chaskiq.Repo.Migrations.AddAddActiveStorageVariantRecords do
  use Ecto.Migration

  def change do
    create table(:storage_variant_records, primary_key: false) do
      add :blob_id, references(:storage_blob, on_delete: :nothing, type: :binary_id)
      add :variation_digest, :string
      timestamps()
    end

    create index(:storage_variant_records, [:blob_id, :variation_digest])
  end
end
