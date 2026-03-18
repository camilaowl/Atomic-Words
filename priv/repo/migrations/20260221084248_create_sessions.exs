defmodule AtomicWords.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :user_id, :integer
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:sessions, [:user_id])
  end
end
