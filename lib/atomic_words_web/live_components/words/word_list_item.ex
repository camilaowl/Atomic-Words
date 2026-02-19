defmodule WordListItem do
  use Phoenix.Component

  import AtomicWordsWeb.CoreComponents

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the element"
  attr :word, :map, required: true, doc: "the original word to display"
  attr :target, :any, default: nil

  def word_list_item(assigns) do
    ~H"""
    <div
      class="word-list-item flex p-2 flex-col justify-items h-fit justify-center rounded-lg shadow-sm w-full"
      {@rest}
    >
      <div class="flex flex-row items-center">
        <h2 class="size-fit text-2xl font-bold">{@word.word}</h2>
        <h2 class="size-fit text-md pl-2  text-gray-500 font-bold">
          {@word.us_transcription}
        </h2>

        <.button
          class="size-10 ml-auto items-center"
          variant="primary"
          phx-click="delete_word"
          phx-value-id={@word.id}
          phx-target={@target}
        >
          <.icon name="hero-trash" class="" />
        </.button>
      </div>

      <div class="flex flex-row items-center">
        <h2 class="size-fit text-xl">
          <%= for translation <- @word.translations do %>
            <span class="mr-2">{translation.text}</span>
          <% end %>
        </h2>
      </div>
    </div>
    """
  end
end
