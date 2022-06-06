defmodule Chaskiq.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      # add :id, :uuid, primary_key: true, null: false
      add :name, :string, null: false
      timestamps(inserted_at: :created_at, updated_at: :updated_at)

    end
  end
end
