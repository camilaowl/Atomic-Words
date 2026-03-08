defmodule AtomicWords.Training.FlashCardViewModel do
  @enforce_keys [:word_id, :session_id, :word, :lang, :translations, :translated_lang]
  defstruct [
    :id,
    :word_id,
    :session_id,
    :word,
    :us_transcription,
    :uk_transcription,
    :lang,
    :translations,
    :translated_lang,
    :is_correct
  ]

  def map(flash_card, word, session_id) do
    %{
      :id => flash_card.id,
      :word_id => word.id,
      :session_id => session_id,
      :word => word.word,
      :us_transcription => word.us_transcription,
      :uk_transcription => word.uk_transcription,
      :lang => word.lang,
      :translations => Enum.map(word.translations, & &1.text),
      :translated_lang => word.translated_lang,
      :is_correct => flash_card.is_correct
    }
  end
end
