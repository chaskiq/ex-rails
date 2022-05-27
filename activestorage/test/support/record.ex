defmodule ActiveStorage.Test.Record do
  @moduledoc """
  Serves as a holder for attachments.  Mirrored by a model in the test Rails app.
  """

  use Ecto.Schema
  # import Ecto.Changeset

  schema "records" do
    timestamps(inserted_at: :created_at, updated_at: :updated_at)
  end

  def record_type do
    "Record"
  end
end
