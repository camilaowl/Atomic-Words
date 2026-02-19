defmodule AtomicWords.Repo.Migrations.AddSelectedTargetLangToPreferencies do
  use Ecto.Migration

  def change do
    alter table(:preferencies) do
      add :selected_target_lang, :string
    end
  end
end
