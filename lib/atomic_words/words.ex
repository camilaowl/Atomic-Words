defmodule AtomicWords.Words do
  import Ecto.Query
  alias AtomicWords.Repo
  alias AtomicWords.Schema.Word
  alias AtomicWords.Schema.WordTranslation
  alias AtomicWords.Schema.UserWords
  alias AtomicWords.Translator
  alias AtomicWords.DictionaryClient
  # alias AtomicWords.Preferencies
  alias AtomicWords.Models.WordModel

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
        |> Translator.translate(target_lang)
        |> IO.inspect(label: "translation result")
        |> dbg()
        |> case do
          {:ok, translated_text} ->
            add_translated_word(input, translated_text, original_lang, target_lang)
            Repo.all(search_partial_query(input))

          _ ->
            []
        end

      _ ->
        []
    end
    |> IO.inspect(label: "fetch_and_add_word result")
  end

  defp search_partial_query(input) do
    from w in Word,
      where: ilike(w.text, ^"%#{input}%"),
      select: w
  end

  @spec add_word(any(), any()) :: any()
  def add_word(word, lang) do
    Repo.insert(%Word{text: word, lang: lang})
  end

  def add_translated_word(original_word, translated_word, original_lang, translated_lang) do
    {:ok, original} = add_word(original_word, original_lang)
    {:ok, translated} = add_word(translated_word, translated_lang)
    bind_words(original.id, translated.id)

    {:ok, original, translated}
    |> IO.inspect(label: "add_translated_word result")
  end

  def add_transcriptions_to_word(word, uk_transcription, us_transcription) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(w in Word, where: w.text == ^word)
    |> Repo.update_all(
      set: [
        uk_transcription: uk_transcription,
        us_transcription: us_transcription,
        updated_at: now
      ]
    )
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
    Repo.insert(%UserWords{user_id: user_id, word_id: word_id},
      on_conflict: :nothing,
      conflict_target: [:user_id, :word_id]
    )
  end

  def delete_user_word_by_id(user_id, word_id) do
    query =
      from uw in UserWords,
        where: uw.user_id == ^user_id and uw.word_id == ^word_id,
        select: uw

    Repo.delete_all(query)
  end

  def last_added_user_words(user_id, limit \\ 30) do
    original_words_query =
      from uw in UserWords,
        join: w in Word,
        on: uw.word_id == w.id,
        where: uw.user_id == ^user_id,
        order_by: [desc: uw.inserted_at],
        limit: ^limit,
        select: w

    # selected_target_lang = Preferencies.selected_target_lang(user_id)

    words_with_translations =
      for word <- Repo.all(original_words_query) do
        translation_query =
          from wt in WordTranslation,
            join: w in Word,
            on: wt.translation_id == w.id,
            where: wt.word_id == ^word.id,
            select: w

        translations = Repo.all(translation_query)

        %WordModel{
          :id => word.id,
          :word => word.text,
          :us_transcription => word.us_transcription,
          :uk_transcription => word.uk_transcription,
          :lang => word.lang,
          :translations => translations,
          :translated_lang => nil,
          :use_case => word.use_case
        }
      end

    words_with_translations
  end
end
