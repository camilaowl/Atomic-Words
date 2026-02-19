defmodule AtomicWords.Repo.Migrations.MergeTranslationsIntoWords do
  use Ecto.Migration

  def up do
    # temporary column to map old translation ids -> new word ids
    alter table(:words) do
      add :_old_translation_id, :integer
    end

    # copy translations into words preserving text, lang and timestamps
    execute("""
    INSERT INTO words (text, lang, transcription, use_case, inserted_at, updated_at, _old_translation_id)
    SELECT text,
           COALESCE(lang, 'en'),
           NULL,
           NULL,
           inserted_at,
           updated_at,
           id
    FROM translations;
    """)

    # point joins to the newly created words
    execute("""
    UPDATE word_translation wt
    SET translation_id = w.id
    FROM words w
    WHERE wt.translation_id = w._old_translation_id;
    """)

    # remove translations table now that data is merged
    drop table(:translations)

    # cleanup temp column
    alter table(:words) do
      remove :_old_translation_id
    end
  end

  def down do
    raise "irreversible migration: restoring translations from words is not implemented"
  end
end
