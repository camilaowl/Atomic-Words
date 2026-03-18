defmodule AtomicWords.Repo.Migrations.AlterFlashCardsIsCorrectNullable do
  use Ecto.Migration

  def change do
    alter table(:flash_cards) do
      modify :is_correct, :boolean, null: true
    end
  end
end
