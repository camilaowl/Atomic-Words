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

  def test(session_id) do
    query =
      from fc in FlashCard,
        where: fc.session_id == ^session_id,
        select: fc

    Repo.all(query)
  end

  def flash_card_answer(flash_card_id, answer) do
    Repo.get(FlashCard, flash_card_id)
    |> FlashCard.changeset(%{is_correct: answer})
    |> Repo.update()
  end

  defp create_flashcards_for_session(user_id, session_id) do
    flash_cards =
      Dictionary.user_words(user_id)
      |> Enum.map(fn word ->
        %FlashCard{}
        |> FlashCard.changeset(%{word_id: word.id, session_id: session_id})
      end)

    Repo.transaction(fn ->
      Enum.each(flash_cards, &Repo.insert!/1)
    end)
  end
end
