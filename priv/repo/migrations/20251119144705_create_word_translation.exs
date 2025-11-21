defmodule AtomicWords.Repo.Migrations.CreateWordTranslation do
  use Ecto.Migration

  def change do
    create table(:word_translation) do
      add :word_id, :integer
      add :translation_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
