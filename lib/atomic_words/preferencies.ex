defmodule AtomicWords.Preferencies do
  import Ecto.Query
  alias AtomicWords.Constants
  alias AtomicWords.Repo
  alias AtomicWords.Accounts.UserPreferencies

  def update_original_lang(user_id, original_lang) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.original_lang_changeset(%{original_lang: original_lang}, %{
          user: %{id: user_id}
        })
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.original_lang_changeset(%{original_lang: original_lang}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def add_target_lang(user_id, target_lang) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.target_lang_changeset(%{target_lang: [target_lang]}, %{
          user: %{id: user_id}
        })
        |> Repo.insert()

      preferencies ->
        updated_target_langs =
          preferencies.target_lang
          |> List.wrap()
          |> Kernel.++([target_lang])
          |> Enum.uniq()

        preferencies
        |> UserPreferencies.target_lang_changeset(%{target_lang: updated_target_langs}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def original_lang(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.original_lang

    Repo.one(query)
  end

  def target_langs(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.target_lang

    Repo.all(query)
  end

  def delete_target_lang(user_id, target_lang) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        {:error, :not_found}

      preferencies ->
        updated_target_langs = List.delete(preferencies.target_lang, target_lang)

        preferencies
        |> UserPreferencies.target_lang_changeset(%{target_lang: updated_target_langs}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def update_selected_target_lang(user_id, selected_target_lang) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.selected_target_lang_changeset(
          %{selected_target_lang: selected_target_lang},
          %{
            user: %{id: user_id}
          }
        )
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.selected_target_lang_changeset(
          %{selected_target_lang: selected_target_lang},
          %{
            user: %{id: user_id}
          }
        )
        |> Repo.update()
    end
  end

  def selected_target_lang(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.selected_target_lang

    Repo.one(query)
  end

  def interface_lang(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.interface_lang

    Repo.one(query) || "en"
  end

  def update_interface_lang(user_id, lang) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.interface_lang_changeset(%{interface_lang: lang}, %{
          user: %{id: user_id}
        })
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.interface_lang_changeset(%{interface_lang: lang}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def default_training_mode(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.default_training_mode

    Repo.one(query) || Constants.training_modes() |> List.first() |> elem(1)
  end

  def update_default_training_mode(user_id, mode) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.default_training_mode_changeset(%{default_training_mode: mode}, %{
          user: %{id: user_id}
        })
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.default_training_mode_changeset(%{default_training_mode: mode}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def default_session_size(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.default_session_size

    Repo.one(query) || Constants.session_sizes() |> List.first() |> elem(1)
  end

  def update_default_session_size(user_id, size) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.default_session_size_changeset(%{default_session_size: size}, %{
          user: %{id: user_id}
        })
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.default_session_size_changeset(%{default_session_size: size}, %{
          user: %{id: user_id}
        })
        |> Repo.update()
    end
  end

  def card_orientation_word_first(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.card_orientation_word_first

    case Repo.one(query) do
      nil -> true
      value -> value
    end
  end

  def update_card_orientation(user_id, word_first) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.card_orientation_changeset(
          %{card_orientation_word_first: word_first},
          %{user: %{id: user_id}}
        )
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.card_orientation_changeset(
          %{card_orientation_word_first: word_first},
          %{user: %{id: user_id}}
        )
        |> Repo.update()
    end
  end

  def auto_add_random_words(user_id) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id,
        select: up.auto_add_random_words

    case Repo.one(query) do
      nil -> false
      value -> value
    end
  end

  def update_auto_add_random_words(user_id, enabled) do
    query =
      from up in UserPreferencies,
        where: up.user_id == ^user_id

    case Repo.one(query) do
      nil ->
        %UserPreferencies{}
        |> UserPreferencies.auto_add_random_words_changeset(
          %{auto_add_random_words: enabled},
          %{user: %{id: user_id}}
        )
        |> Repo.insert()

      preferencies ->
        preferencies
        |> UserPreferencies.auto_add_random_words_changeset(
          %{auto_add_random_words: enabled},
          %{user: %{id: user_id}}
        )
        |> Repo.update()
    end
  end
end
