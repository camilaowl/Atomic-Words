defmodule LangSwither do
  use Phoenix.Component

  import AtomicWordsWeb.CoreComponents

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the element"
  attr :origin_lang, :string, required: true, doc: "the original language"
  attr :target_lang, :string, required: true, doc: "the target language"

  def lang_swither(assigns) do
    ~H"""
    <div class="flex flex-row items-center gap-x-1">
      <h1 class="mx-1">{@origin_lang}</h1>

      <button
        {@rest}
        class="p-2 rounded-full transition-colors flex items-center justify-center bg-orange-400 hover:bg-orange-600"
      >
        <.icon name="hero-arrows-right-left" class="w-5 h-5 text-white" />
      </button>

      <h1 class="mx-1">{@target_lang}</h1>
    </div>
    """
  end
end
