defmodule AtomicWords.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "words" do
    field :text, :string
    field :transcription, :string
    field :use_case, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(word, attrs) do
    word
    |> cast(attrs, [:text, :transcription, :use_case])
    |> validate_required([:text, :transcription, :use_case])
  end
end
