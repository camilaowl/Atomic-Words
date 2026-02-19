defmodule AtomicWords.Repo.Migrations.CreateTranscriptions do
  use Ecto.Migration

  def change do
    create table(:transcriptions) do
      add :word, :string
      add :uk_transcription, :string
      add :us_transcription, :string

      timestamps(type: :utc_datetime)
    end

    create index(:transcriptions, [:word])
  end
end
