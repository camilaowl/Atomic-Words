defmodule AtomicWords.WordTranslation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "word_translation" do
    field :word_id, :integer
    field :translation_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(word_translation, attrs) do
    word_translation
    |> cast(attrs, [:word_id, :translation_id])
    |> validate_required([:word_id, :translation_id])
  end
end
