defmodule AtomicWords.Repo.Migrations.DeduplicatePreferenciesAndUniqueUserId do
  use Ecto.Migration

  def up do
    execute("""
    DELETE FROM preferencies
    WHERE id NOT IN (
      SELECT MAX(id)
      FROM preferencies
      GROUP BY user_id
    )
    """)

    drop index(:preferencies, [:user_id])
    create unique_index(:preferencies, [:user_id])
  end

  def down do
    drop index(:preferencies, [:user_id])
    create index(:preferencies, [:user_id])
  end
end
