defmodule AtomicWords.Schema.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "words" do
    field :text, :string
    field :transcription, :string
    field :uk_transcription, :string
    field :us_transcription, :string
    field :use_case, :string
    field :lang, :string, default: "en"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(word, attrs) do
    word
    |> cast(attrs, [:text, :transcription, :uk_transcription, :us_transcription, :use_case, :lang])
    |> validate_required([:text, :transcription, :use_case, :lang])
  end
end
