defmodule AtomicWords.Repo.Migrations.CreateWords do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :text, :string
      add :transcription, :string
      add :use_case, :string

      timestamps(type: :utc_datetime)
    end
  end
end
