defmodule AtomicWords.Training do
  alias AtomicWords.Training.Session
  alias AtomicWords.Training.FlashCard
  alias AtomicWords.Dictionary
  alias AtomicWords.Repo
  import Ecto.Query
  alias AtomicWords.Training.FlashCardViewModel

  def start_training(user_id) do
    %Session{}
    |> Session.changeset(%{user_id: user_id, completed_at: nil}, user_id)
    |> Repo.insert()
    |> case do
      {:ok, session} ->
        create_flashcards_for_session(Dictionary.user_words(user_id), session.id)
        {:ok, session}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def start_training_with_mode("my_words", limit, user_id) do
    %Session{}
    |> Session.changeset(%{user_id: user_id, completed_at: nil}, user_id)
    |> Repo.insert()
    |> case do
      {:ok, session} ->
        user_words = Dictionary.user_words(user_id)
        user_words_with_limit = take_random(user_words, limit)
        create_flashcards_for_session(user_words_with_limit, session.id)
        {:ok, session}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def start_training_with_mode("difficult", limit, user_id),
    do: start_training_with_mode("my_words", limit, user_id)

  def start_training_with_mode("random", limit, user_id) do
    %Session{}
    |> Session.changeset(%{user_id: user_id, completed_at: nil}, user_id)
    |> Repo.insert()
    |> case do
      {:ok, session} ->
        create_flashcards_for_session(Dictionary.random_words(limit), session.id)
        {:ok, session}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def start_training_with_mode(_mode, _limit, user_id), do: start_training(user_id)

  defp take_random(list, limit) when is_binary(limit) do
    case Integer.parse(limit) do
      {int, _} when int > 0 -> Enum.take_random(list, int)
      _ -> Enum.shuffle(list)
    end
  end

  defp take_random(list, limit), do: Enum.take_random(list, limit)

  def complete_training(session_id, user_id) do
    Repo.get(Session, session_id)
    |> Session.changeset(%{completed_at: DateTime.utc_now()}, user_id)
    |> Repo.update()
  end

  def active_session_for_user(user_id) do
    query =
      from s in Session,
        where: s.user_id == ^user_id and is_nil(s.completed_at),
        order_by: [desc: s.inserted_at],
        limit: 1

    Repo.one(query)
  end

  @spec flashcards_for_session(any()) :: list()
  def flashcards_for_session(session_id) do
    query =
      from fc in FlashCard,
        where: fc.session_id == ^session_id,
        select: fc

    cards =
      for flash_card <- Repo.all(query) do
        word = Dictionary.word_by_id(flash_card.word_id)
        FlashCardViewModel.map(flash_card, word, session_id)
      end

    cards
  end

  def current_and_next_flash_cards(session_id) do
    query =
      from fc in FlashCard,
        where: fc.session_id == ^session_id and is_nil(fc.is_correct),
        order_by: [asc: fc.inserted_at, asc: fc.id]

    flash_cards =
      for flash_card <- Repo.all(query) do
        word = Dictionary.word_by_id(flash_card.word_id)
        FlashCardViewModel.map(flash_card, word, session_id)
      end

    current_card = Enum.at(flash_cards, 0)
    next_card = Enum.at(flash_cards, 1)

    {current_card, next_card}
  end

  def all_flashcards_answered?(session_id) do
    query =
      from fc in FlashCard,
        where: fc.session_id == ^session_id and is_nil(fc.is_correct)

    Repo.all(query) == []
  end

  def flash_card_answer(flash_card_id, true) do
    Repo.get(FlashCard, flash_card_id)
    |> FlashCard.changeset(%{is_correct: true})
    |> Repo.update()
  end

  def flash_card_answer(flash_card_id, false) do
    Repo.get(FlashCard, flash_card_id)
    |> FlashCard.changeset(%{is_correct: false})
    |> Repo.update()
    |> case do
      {:ok, flash_card} ->
        flashcard_changeset_for_session(flash_card.word_id, flash_card.session_id)
        |> Repo.insert()

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp create_flashcards_for_session(word_list, session_id) do
    Enum.map(word_list, fn word ->
      flashcard_changeset_for_session(word.id, session_id)
      |> Repo.insert()
    end)
  end

  defp flashcard_changeset_for_session(word_id, session_id) do
    %FlashCard{}
    |> FlashCard.changeset(%{word_id: word_id, session_id: session_id, is_correct: nil})
  end
end
