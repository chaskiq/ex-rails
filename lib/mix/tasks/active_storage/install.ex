defmodule Mix.Tasks.ExActiveStorage.Install do
  @shortdoc "generates active storage migration file for the database"

  use Mix.Task
  import Mix.Generator

  def run(_args) do
    path = Path.relative_to("priv/repo/migrations", Mix.Project.app_path())
    blob_file = Path.join(path, "#{timestamp()}_create_storage_blob.exs")
    variant_file = Path.join(path, "#{timestamp()}_create_active_storage_variant_records.exs")
    create_directory(path)

    create_file(blob_file, """
    defmodule Repo.Migrations.CreateStorageBlob do
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
    """)

    create_file(variant_file, """
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
    """)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
