defmodule AtomicWords.Repo.Migrations.AddTranscriptionsToWords do
  use Ecto.Migration

  def change do
    alter table(:words) do
      add :uk_transcription, :string
      add :us_transcription, :string
    end
  end
end
