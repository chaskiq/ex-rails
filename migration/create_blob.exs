defmodule Chaskiq.Repo.Migrations.CreateStorageBlob do
  use Ecto.Migration

  def change do
    create table(:storage_blob, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :filename, :string
      add :content_type, :string
      add :metadata, :map
      add :byte_size, :integer
      add :checksum, :string
      add :service_name, :string

      timestamps()
    end
  end
end
