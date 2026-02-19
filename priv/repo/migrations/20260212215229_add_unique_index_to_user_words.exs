defmodule AtomicWords.Repo.Migrations.AddUniqueIndexToUserWords do
  use Ecto.Migration

  def up do
    # remove duplicate rows so the unique index can be created successfully
    execute("""
    DELETE FROM user_words a
    USING user_words b
    WHERE a.id > b.id
      AND a.user_id = b.user_id
      AND a.word_id = b.word_id
    """)

    create unique_index(:user_words, [:user_id, :word_id])
  end

  def down do
    drop_if_exists(index(:user_words, [:user_id, :word_id]))
  end
end
