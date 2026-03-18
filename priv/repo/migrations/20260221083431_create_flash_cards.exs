defmodule AtomicWords.Repo.Migrations.CreateFlashCards do
  use Ecto.Migration

  def change do
    create table(:flash_cards) do
      add :word_id, :integer
      add :session_id, :integer
      add :is_correct, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:flash_cards, [:user_id])
  end
end
