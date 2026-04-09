defmodule AtomicWords.Repo.Migrations.AddTranscriptionVariantToPreferencies do
  use Ecto.Migration

  def change do
    alter table(:preferencies) do
      add :transcription_variant, :string, default: "us"
    end
  end
end
