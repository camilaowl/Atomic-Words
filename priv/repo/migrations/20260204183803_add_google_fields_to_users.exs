defmodule AtomicWords.Repo.Migrations.AddGoogleFieldsToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :google_uid, :string
      add :google_token, :string
      add :google_refresh_token, :string
      modify :hashed_password, :string, null: true
    end

    create unique_index(:users, [:google_uid, :google_token, :google_refresh_token])
  end

  def down do
    drop index(:users, [:google_uid, :google_token, :google_refresh_token])

    alter table(:users) do
      remove :google_uid
      remove :google_token
      remove :google_refresh_token
      modify :hashed_password, :string, null: false
    end
  end
end
