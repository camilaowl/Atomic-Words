defmodule WordListItem do
  use Phoenix.Component

  import AtomicWordsWeb.CoreComponents

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the element"
  attr :word, :map, required: true, doc: "the original word to display"

  def word_list_item(assigns) do
    ~H"""
    <div
      class="word-list-item flex flex-row justify-items-stretch h-12 justify-center rounded-lg shadow-sm w-full"
      {@rest}
    >
      <div class="flex flex-row items-center">
        <h2 class="size-fit text-2xl  text-green-500 font-bold border-2 border-green-500 bg-green-100 rounded-lg ">
          {@word.lang}
        </h2>
        <h2 class="size-fit p-2 text-2xl font-bold">{@word.word}</h2>
      </div>

      <div class="flex flex-row items-center">
        <h2 class="size-fit text-2xl  text-green-500 font-bold border-2 border-green-500 bg-green-100 rounded-lg ">
          {@word.translated_lang}
        </h2>
        <h2 class="size-fit p-2 text-2xl font-bold">
          <%= for translation <- @word.translations do %>
            <span class="mr-2">{translation.text}</span>
          <% end %>
        </h2>
      </div>
    </div>
    """
  end
end
