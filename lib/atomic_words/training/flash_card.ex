defmodule AtomicWords.Training.FlashCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "flash_cards" do
    field :word_id, :integer
    field :session_id, :integer
    field :is_correct, :boolean, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(flash_cards, attrs) do
    flash_cards
    |> cast(attrs, [:word_id, :session_id, :is_correct])
    |> validate_required([:word_id, :session_id])
  end
end
