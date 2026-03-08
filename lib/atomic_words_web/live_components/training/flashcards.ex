defmodule AtomicWordsWeb.LiveComponents.Training.Flashcards do
  use AtomicWordsWeb, :live_component

  attr :current_scope, :any, required: true
  attr :flash_card, :any, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row w-full justify-center">
      <div class="w-full">
        <div
          id={"flashcard-swipe-#{@flash_card.id}"}
          class="flex flex-col gap-8 items-center justify-center"
          data-flashcard-id={@flash_card.id}
          phx-hook="FlashcardSwipe"
        >
          <div
            id={"flashcard-#{@flash_card.id}"}
            class="flashcard w-full h-56"
            phx-click={JS.toggle_class("is-flipped", to: "#flashcard-#{@flash_card.id}")}
          >
            <div class="flashcard-inner">
              <div class="flashcard-face flashcard-front flex flex-col items-center justify-center bg-white rounded-lg shadow-md p-6">
                <h2 class="text-xl font-bold">{@flash_card.word}</h2>
              </div>
              <div class="flashcard-face flashcard-back flex flex-col items-center justify-center bg-white rounded-lg shadow-md p-6">
                <p class="text-gray-600">{@flash_card.us_transcription}</p>
                <div class="mt-2 flex flex-wrap gap-2">
                  <%= for translation <- @flash_card.translations do %>
                    <span class="px-2 py-1 rounded-md bg-gray-100 text-gray-800 text-md">
                      {translation}
                    </span>
                  <% end %>
                </div>
              </div>
            </div>
          </div>

          <div class="flex flex-row gap-8 items-center justify-center">
            <.button
              class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors mb-4"
              data-flashcard-action="left"
              type="button"
            >
              Wrong answer
            </.button>
            <.button
              class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors mb-4"
              data-flashcard-action="right"
              type="button"
            >
              Right answer
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
