defmodule AtomicWords.Models.Word do
  @enforce_keys [:word, :lang, :translations, :translated_lang]
  defstruct [:word, :lang, :translations, :translated_lang, :usecase]
end
