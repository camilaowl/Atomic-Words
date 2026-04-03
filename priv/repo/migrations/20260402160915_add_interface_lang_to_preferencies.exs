defmodule AtomicWords.Repo.Migrations.AddInterfaceLangToPreferencies do
  use Ecto.Migration

  def change do
    alter table(:preferencies) do
      add :interface_lang, :string, default: "en"
    end
  end
end
