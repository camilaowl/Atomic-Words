defmodule AtomicWords.Translator do

  import Ecto.Query

  @moduledoc """
  Handles translation of words using Google Translate API.
  """
  alias GoogleApi.Translate.V2.Connection
  alias GoogleApi.Translate.V2.Api.Translations
  alias AtomicWords.Schema.Word

  def translate(text, target_lang \\ "uk") do
    with {:ok, token} <- Goth.fetch(AtomicWords),
         conn <- Connection.new(token.token),
         {:ok, response} <- Translations.language_translations_list(conn, text, target_lang) do
            response.translations
            |> List.first()
            |> Map.get(:translatedText)
            |> then(&{:ok, &1})
          else
            error -> {:error, error}
          end
  end

  def test(text, target_lang \\ "uk") do
    with {:ok, token} <- Goth.fetch(AtomicWords),
         conn <- Connection.new(token.token),
         {:ok, response} <- Translations.language_translations_list(conn, text, target_lang) do
            response
          else
            error -> {:error, error}
          end
  end

  def read_file(path) do
    File.open(path, [:read], fn file ->
      IO.read(file, :all)
      |> String.split("\n", trim: true)
    end)
  end

  def add_word(word) do
    #{:ok, translation} = translate(word, "uk")
    Repo.insert(%Word{text: word})
  end

  @spec setup_words_from_file(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) :: :ok
  def setup_words_from_file(path) do
    {:ok, words} = read_file(path)
    words
    |> Enum.uniq()
    |> Enum.each(&add_word/1)
  end

  def read_transcriptions_from_file(path) do
    File.open(path, [:read], fn file ->
      IO.read(file, :all)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [word, transcription] = String.split(line, "\t")
        {word, transcription}
      end)
    end)
  end

  def test_migrations() do
    Repo.all(from w in Word, where: w.lang == "uk")
  end

end
