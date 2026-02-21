defmodule AtomicWords.Training.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :user_id, :integer
    field :completed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sessions, attrs, user_scope) do
    sessions
    |> cast(attrs, [:user_id, :completed_at])
    |> validate_required([:user_id, :completed_at])
    |> put_change(:user_id, user_scope.user.id)
  end
end
