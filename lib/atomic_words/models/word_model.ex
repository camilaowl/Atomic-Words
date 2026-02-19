defmodule AtomicWords.Models.WordModel do
  @enforce_keys [:word, :lang, :translations, :translated_lang]
  defstruct [
    :id,
    :word,
    :us_transcription,
    :uk_transcription,
    :lang,
    :translations,
    :translated_lang,
    :use_case
  ]
end
