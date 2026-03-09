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
        create_flashcards_for_session(user_id, session.id)
        {:ok, session}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

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
        where: fc.session_id == ^session_id and is_nil(fc.is_correct)

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

  defp create_flashcards_for_session(user_id, session_id) do
    Dictionary.user_words(user_id)
    |> Enum.map(fn word ->
      flashcard_changeset_for_session(word.id, session_id)
      |> Repo.insert()
    end)
  end

  defp flashcard_changeset_for_session(word_id, session_id) do
    %FlashCard{}
    |> FlashCard.changeset(%{word_id: word_id, session_id: session_id, is_correct: nil})
  end
end
