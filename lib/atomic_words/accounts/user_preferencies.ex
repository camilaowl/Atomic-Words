defmodule AtomicWords.Accounts.UserPreferencies do
  use Ecto.Schema
  import Ecto.Changeset

  schema "preferencies" do
    field :original_lang, :string
    field :target_lang, {:array, :string}
    field :selected_target_lang, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:original_lang, :target_lang])
    |> validate_required([:original_lang, :target_lang])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def original_lang_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:original_lang])
    |> validate_required([:original_lang])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def target_lang_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:target_lang])
    |> validate_required([:target_lang])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def selected_target_lang_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:selected_target_lang])
    |> validate_required([:selected_target_lang])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end
end
