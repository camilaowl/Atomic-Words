defmodule AtomicWords.Models.WordModel do
  @enforce_keys [:word, :lang, :translations, :translated_lang]
  defstruct [:word, :transcription, :lang, :translations, :translated_lang, :use_case]
end
