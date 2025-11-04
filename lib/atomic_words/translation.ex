defmodule AtomicWords.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field :text, :string
    field :lang, :string
    field :word_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:text, :lang, :word_id])
    |> validate_required([:text, :lang, :word_id])
  end
end
