defmodule AtomicWords.Repo.Migrations.WordsAddLangColumn do
  use Ecto.Migration

  def change do
    alter table("words") do
      add :lang, :string, default: "en", null: false
    end
  end
end
