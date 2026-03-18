defmodule AtomicWords.Repo.Migrations.SetFlashCardsIsCorrectDefaultToNil do
  use Ecto.Migration

  def change do
    alter table(:flash_cards) do
      modify :is_correct, :boolean, default: nil, null: true
    end
  end
end
