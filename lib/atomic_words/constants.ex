defmodule AtomicWords.Constants do
  @languages [
    {"Arabic", "ar"},
    {"Chinese (Simplified)", "zh-CN"},
    {"Chinese (Traditional)", "zh-TW"},
    {"Czech", "cs"},
    {"Danish", "da"},
    {"Dutch", "nl"},
    {"English", "en"},
    {"Finnish", "fi"},
    {"French", "fr"},
    {"German", "de"},
    {"Greek", "el"},
    {"Hebrew", "he"},
    {"Hindi", "hi"},
    {"Hungarian", "hu"},
    {"Indonesian", "id"},
    {"Italian", "it"},
    {"Japanese", "ja"},
    {"Korean", "ko"},
    {"Malay", "ms"},
    {"Norwegian", "no"},
    {"Persian", "fa"},
    {"Polish", "pl"},
    {"Portuguese", "pt"},
    {"Romanian", "ro"},
    {"Spanish", "es"},
    {"Swedish", "sv"},
    {"Thai", "th"},
    {"Turkish", "tr"},
    {"Ukrainian", "uk"},
    {"Vietnamese", "vi"}
  ]

  @training_modes [
    {"My words", "my_words"},
    {"Difficult", "difficult"},
    {"Random words", "random"}
  ]

  @session_sizes [
    {"15 words", 15},
    {"30 words", 30},
    {"45 words", 45}
  ]

  def native_languages, do: @languages
  def training_modes, do: @training_modes
  def session_sizes, do: @session_sizes
end
