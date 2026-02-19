defmodule AtomicWords.Repo.Migrations.CreatePreferencies do
  use Ecto.Migration

  def change do
    create table(:preferencies) do
      add :original_lang, :string
      add :target_lang, {:array, :string}
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:preferencies, [:user_id])
  end
end
