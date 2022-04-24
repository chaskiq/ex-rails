defmodule ActiveStorage.Test.Setup do
  def cleanup_db do
    Ecto.Adapters.SQL.query!(
      ActiveStorage.Test.Repo,
      "TRUNCATE active_storage_blobs, active_storage_attachments, active_storage_variant_records RESTART IDENTITY",
      []
    )

    :ok
  end
end
