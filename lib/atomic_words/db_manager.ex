defmodule AtomicWords.DbManager do
  import Ecto.Query
  alias AtomicWords.Translator
  alias AtomicWords.Repo
  alias AtomicWords.Schema.Word
  alias AtomicWords.Schema.WordTranslation
  alias AtomicWords.Schema.UserWords
  alias AtomicWords.Words

  @us_transcriptions_path "priv/static/en_US_transcriptions.txt"
  @uk_transcriptions_path "priv/static/en_UK_transcriptions.txt"
  @words_path "priv/static/oxford5000_words.txt"
  @translation_target_lang "uk"
  @translation_origin_lang "en"
  @chunk_size 10_000

  def clear_db do
    Repo.delete_all(UserWords)
    Repo.delete_all(WordTranslation)
    Repo.delete_all(Word)
    Repo.delete_all(AtomicWords.Transcriptions)
  end

  def reset_db_from_file() do
    clear_db()
    fill_transcriptions_from_file()
    fill_words_from_file()
  end

  @spec read_transcriptions_from_file(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) :: {:error, atom()} | {:ok, any()}
  defp read_transcriptions_from_file(path) do
    with {:ok, contents} <- File.read(path) do
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [word, transcription] = String.split(line, "\t")
        {word, transcription}
      end)
      |> then(&{:ok, &1})
    end
  end

  def fill_transcriptions_from_file() do
    with {:ok, us_transcriptions} <-
           read_transcriptions_from_file(@us_transcriptions_path),
         {:ok, uk_transcriptions} <-
           read_transcriptions_from_file(@uk_transcriptions_path) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      us_transcriptions
      |> Enum.map(fn {word, us} ->
        %{
          word: word,
          us_transcription: us,
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.each(fn batch ->
        Repo.insert_all(
          AtomicWords.Transcriptions,
          batch,
          on_conflict: {:replace, [:us_transcription]},
          conflict_target: [:word]
        )
      end)

      uk_transcriptions
      |> Enum.map(fn {word, uk} ->
        %{
          word: word,
          uk_transcription: uk,
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.each(fn batch ->
        Repo.insert_all(
          AtomicWords.Transcriptions,
          batch,
          on_conflict: {:replace, [:uk_transcription]},
          conflict_target: [:word]
        )
      end)
    end
  end

  def read_file(path) do
    with {:ok, contents} <- File.read(path) do
      contents
      |> String.split("\n", trim: true)
      |> then(&{:ok, &1})
    end
  end

  def fill_words_from_file() do
    {:ok, words} = read_file(@words_path)

    words
    |> Enum.uniq()
    |> Enum.each(fn word ->
      with {:ok, translated_text} <- Translator.translate(word, @translation_target_lang) do
        Words.add_translated_word(
          word,
          translated_text,
          @translation_origin_lang,
          @translation_target_lang
        )

        case Repo.get_by(AtomicWords.Transcriptions, word: word) do
          nil ->
            :ok

          transcriptions ->
            Words.add_transcriptions_to_word(
              word,
              transcriptions.uk_transcription,
              transcriptions.us_transcription
            )
        end
      end
    end)
  end

  def add_transcriptions_to_existing_words() do
    Repo.all(Word)
    |> Enum.each(fn word ->
      case Repo.get_by(AtomicWords.Transcriptions, word: word.text) do
        nil ->
          :ok

        transcriptions ->
          Words.add_transcriptions_to_word(
            word.text,
            transcriptions.uk_transcription,
            transcriptions.us_transcription
          )
      end
    end)
  end
end
