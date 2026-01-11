defmodule AtomicWords.Words do
  import Ecto.Query
  alias AtomicWords.Repo
  alias AtomicWords.Schema.Word
  alias AtomicWords.Schema.WordTranslation
  alias AtomicWords.Schema.UserWords
  alias AtomicWords.Translator
  alias AtomicWords.DictionaryClient

  def search_partial(input, original_lang, target_lang) do
    query = search_partial_query(input)

    case Repo.all(query) do
      [] -> fetch_and_add_word(input, original_lang, target_lang)
      results -> results
    end
  end

  def fetch_and_add_word(input, original_lang, target_lang) do
    case DictionaryClient.valid_word(input) do
      {:found, _body} ->
        input
        |> Translator.translate(original_lang)
        |> case do
          {:ok, translated_text} ->
            add_translated_word(input, translated_text, original_lang, target_lang)
            Repo.all(search_partial_query(input))

          _ ->
            nil
        end

      _ ->
        nil
    end
  end

  defp search_partial_query(input) do
    from w in Word,
      where: ilike(w.text, ^"%#{input}%"),
      select: w
  end

  def add_word(word, lang) do
    Repo.insert(%Word{text: word, lang: lang})
  end

  def add_translated_word(original_word, translated_word, original_lang, translated_lang) do
    {:ok, original} = Repo.insert(%Word{text: original_word, lang: original_lang})
    {:ok, translated} = Repo.insert(%Word{text: translated_word, lang: translated_lang})
    bind_words(original.id, translated.id)
    {:ok, original, translated}
  end

  def bind_words(word_id, translation_id) do
    Repo.insert(%WordTranslation{word_id: word_id, translation_id: translation_id})
  end

  def find_user_words_by_user_id(user_id) do
    query =
      from uw in UserWords,
        where: uw.user_id == ^user_id,
        select: uw

    Repo.all(query)
  end

  def add_user_word(user_id, word_id) do
    Repo.insert(%UserWords{user_id: user_id, word_id: word_id})
  end

  def delete_user_word_by_id(word_id) do
    query =
      from uw in UserWords,
        where: uw.word_id == ^word_id,
        select: uw

    Repo.delete_all(query)
  end

  def last_added_user_words(user_id, limit) do
    query =
      from uw in UserWords,
        join: w in Word,
        on: uw.word_id == w.id,
        where: uw.user_id == ^user_id,
        order_by: [desc: uw.inserted_at],
        limit: ^limit,
        select: w

    Repo.all(query)
  end
end
