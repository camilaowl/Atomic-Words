defmodule AtomicWords.Repo.Migrations.AddUniqueIndexOnWordInTranscriptions do
  use Ecto.Migration

  def change do
    create unique_index(:transcriptions, [:word])
  end
end
