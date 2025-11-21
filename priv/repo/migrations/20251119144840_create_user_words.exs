defmodule AtomicWords.Repo.Migrations.CreateUserWords do
  use Ecto.Migration

  def change do
    create table(:user_words) do
      add :user_id, :integer
      add :word_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
