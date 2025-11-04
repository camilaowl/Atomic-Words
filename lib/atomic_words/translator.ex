defmodule AtomicWords.Translator do

  @moduledoc """
  Handles translation of words using Google Translate API.
  """
  alias GoogleApi.Translate.V2.Connection
  alias GoogleApi.Translate.V2.Api.Translations

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

  defp read_file(path) do
    File.read(path)
  end



end
