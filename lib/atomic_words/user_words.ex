defmodule AtomicWords.UserWords do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_words" do
    field :user_id, :integer
    field :word_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_words, attrs) do
    user_words
    |> cast(attrs, [:user_id, :word_id])
    |> validate_required([:user_id, :word_id])
  end
end
