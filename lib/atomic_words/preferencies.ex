defmodule AtomicWords.Preferencies do
  import Ecto.Query
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
end
