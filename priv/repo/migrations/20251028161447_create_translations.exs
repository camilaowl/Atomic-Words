defmodule AtomicWords.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :text, :string
      add :lang, :string
      add :word_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
