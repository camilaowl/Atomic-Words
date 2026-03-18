defmodule AtomicWords.Transcriptions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transcriptions" do
    field :word, :string
    field :uk_transcription, :string
    field :us_transcription, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transcriptions, attrs, _user_scope) do
    transcriptions
    |> cast(attrs, [:word, :uk_transcription, :us_transcription])
    |> validate_required([:word, :uk_transcription, :us_transcription])
  end
end
