defmodule AtomicWords.Repo.Migrations.AddTrainingPreferencesToPreferencies do
  use Ecto.Migration

  def change do
    alter table(:preferencies) do
      add :default_training_mode, :string, default: "my_words"
      add :default_session_size, :integer, default: 15
      add :card_orientation_word_first, :boolean, default: true
      add :auto_add_random_words, :boolean, default: false
    end
  end
end
