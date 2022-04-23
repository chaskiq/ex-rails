defmodule Mix.Tasks.ActiveStorage.Install do
  @shortdoc "generates active storage migration file for the database"

  use Mix.Task
  import Mix.Generator

  def run(_args) do
    path = Path.relative_to("priv/repo/migrations", Mix.Project.app_path())
    migration_file = Path.join(path, "#{timestamp()}_create_active_storage_tables.exs")

    create_directory(path)

    create_file(migration_file, """
      create table(:active_storage_blobs) do
        # add :id, :uuid, primary_key: true, null: false
        add :key, :string, null: false
        add :filename, :string, null: false
        add :content_type, :string
        add :metadata, :string
        add :service_name, :string, null: false
        add :byte_size, :integer, null: false
        add :checksum, :string

        timestamps()
      end

      create unique_index(:active_storage_blobs, [:key])

      create table(:active_storage_attachments) do
        add :name, :string, null: false
        add :record_id, :integer
        add :record_type, :string

        add :blob_id, :integer
        add :blob_type, :string

        timestamps()
      end

      create index("active_storage_attachments", [:record_type, :record_id, :name, :blob_id],
              name: :index_active_storage_attachments_uniqueness,
              unique: true
            )

      create index("active_storage_attachments", [:blob_id],
              name: :index_active_storage_attachments_on_blob_id,
              unique: false
            )

      create table(:active_storage_variant_records) do
        add :blob_id, references(:storage_blob, on_delete: :nothing, type: :binary_id)
        add :variation_digest, :string, null: false
        timestamps()
      end

      create index(:active_storage_variant_records, [:blob_id, :variation_digest])
      # with: [group_id: :group_id])
      # add :blob_id, references("active_storage_blobs")
    """)

  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
