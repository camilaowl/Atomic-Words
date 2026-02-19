defmodule AtomicWords.DictionaryClient do
  @base_url "https://api.dictionaryapi.dev/api/v2/entries"

  def valid_word(word, lang \\ "en") do
    word
    |> normalize_word()
    |> request(lang)
    |> handle_response()
  end

  defp normalize_word(word) do
    word
    |> String.downcase()
    |> String.trim()
  end

  defp request(word, language) do
    url = "#{@base_url}/#{language}/#{word}"

    Finch.build(:get, url)
    |> Finch.request(AtomicWords.Finch)
  end

  defp handle_response({:ok, %Finch.Response{status: 200, body: body}}), do: {:found, body}
  defp handle_response({:ok, %Finch.Response{status: 404}}), do: {:not_found, []}
  defp handle_response(_), do: {:error, :request_failed}
end
