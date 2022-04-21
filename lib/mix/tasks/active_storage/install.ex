defmodule Mix.Tasks.ActiveStorage.Install do
  @shortdoc "generates active storage migration file for the database"

  use Mix.Task
  import Mix.Generator

  def run(_args) do
    path = Path.relative_to("priv/repo/migrations", Mix.Project.app_path())
    blob_file = Path.join(path, "#{timestamp()}_create_storage_blob.exs")
    variant_file = Path.join(path, "#{timestamp()}_create_active_storage_variant_records.exs")
    attachment_file = Path.join(path, "#{timestamp()}_create_active_storage_attachments.exs")

    create_directory(path)

    create_file(blob_file, """
    defmodule Repo.Migrations.CreateStorageBlob do
      def change do
        create table(:active_storage_blobs, primary_key: true) do
          # add :id, :uuid, primary_key: true, null: false
          add :key, :string, null: false
          add :filename, :string, null: false
          add :content_type, :string
          add :metadata, :map
          add :service_name, :string, null: false
          add :byte_size, :integer, null: false
          add :checksum, :string

          timestamps()
        end

        create unique_index(:active_storage_blobs, [:key])
      end
    end
    """)


    #create_table :active_storage_attachments, id: primary_key_type do |t|
    #  t.string     :name,     null: false
    #  t.references :record,   null: false, polymorphic: true, index: false, type: foreign_key_type
    #  t.references :blob,     null: false, type: foreign_key_type

    #  if connection.supports_datetime_with_precision?
    #    t.datetime :created_at, precision: 6, null: false
    #  else
    #    t.datetime :created_at, null: false
    #  end

    #  t.index [ :record_type, :record_id, :name, :blob_id ], name: :index_active_storage_attachments_uniqueness, unique: true
    #  t.foreign_key :active_storage_blobs, column: :blob_id
    #end

    create_file(attachment_file, """
    defmodule Chaskiq.Repo.Migrations.CreateActiveStorageAttachments do
      use Ecto.Migration

      def change do
        create table(:active_storage_attachments, primary_key: true) do
          add :name, :string, null: false
          add :record_id, :integer
          add :record_type, :string

          add :blob_id, :integer
          add :blob_type, :string

          timestamps()
        end

        create index("attachments", [:record_type, :record_id, :name, :blob_id], name: :index_active_storage_attachments_uniqueness, unique: true)
        create index("blob_id", [:blob_id], name: :index_active_storage_attachments_on_blob_id, unique: false)

      end
    end
    """)


    #create_table :active_storage_variant_records, id: primary_key_type do |t|
    #  t.belongs_to :blob, null: false, index: false, type: foreign_key_type
    #  t.string :variation_digest, null: false

    #  t.index [ :blob_id, :variation_digest ], name: :index_active_storage_variant_records_uniqueness, unique: true
    #  t.foreign_key :active_storage_blobs, column: :blob_id
    #end

    create_file(variant_file, """
    defmodule Chaskiq.Repo.Migrations.AddAddActiveStorageVariantRecords do
      use Ecto.Migration

      def change do
        create table(:active_storage_variant_records, primary_key: true) do
          add :blob_id, references(:storage_blob, on_delete: :nothing, type: :binary_id)
          add :variation_digest, :string, null: false
          timestamps()
        end

        create index(:active_storage_variant_records, [:blob_id, :variation_digest])
        add :blob_id, references("active_storage_blobs") # with: [group_id: :group_id])

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
