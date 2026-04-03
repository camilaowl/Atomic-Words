defmodule AtomicWords.Accounts.UserPreferencies do
  use Ecto.Schema
  import Ecto.Changeset

  schema "preferencies" do
    field :original_lang, :string
    field :target_lang, {:array, :string}
    field :selected_target_lang, :string
    field :interface_lang, :string, default: "en"
    field :default_training_mode, :string, default: "my_words"
    field :default_session_size, :integer, default: 15
    field :card_orientation_word_first, :boolean, default: true
    field :auto_add_random_words, :boolean, default: false
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

  def interface_lang_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:interface_lang])
    |> validate_required([:interface_lang])
    |> validate_inclusion(:interface_lang, ["en", "uk"])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def default_training_mode_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:default_training_mode])
    |> validate_required([:default_training_mode])
    |> validate_inclusion(:default_training_mode, ["my_words", "difficult", "random"])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def default_session_size_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:default_session_size])
    |> validate_required([:default_session_size])
    |> validate_inclusion(:default_session_size, [15, 30, 45])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def card_orientation_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:card_orientation_word_first])
    |> validate_required([:card_orientation_word_first])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end

  def auto_add_random_words_changeset(user_preferencies, attrs, user_scope) do
    user_preferencies
    |> cast(attrs, [:auto_add_random_words])
    |> validate_required([:auto_add_random_words])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:user_id)
  end
end
