defmodule AtomicWordsWeb.LiveComponents.Training.Flashcards do
  use AtomicWordsWeb, :live_component

  attr :current_scope, :any, required: true
  attr :flash_card, :any, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row w-full justify-center">
      <div class="w-1/2">
        <h1 class="text-3xl font-bold mb-4">Flashcards</h1>
        <div class="flex flex-row gap-8 items-center justify-center">
          <.button
            class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors mb-4"
            phx-value-id={@flash_card.id}
            phx-click="wrong_answer"
          >
            Wrong answer
          </.button>
          <div class="flashcard p-4 bg-white rounded-lg shadow-md">
            <h2 class="text-xl font-bold">{@flash_card.word}</h2>
            <p class="text-gray-600">{@flash_card.us_transcription}</p>
            <div class="mt-2">
              <%= for translation <- @flash_card.translations do %>
                <span class="mr-2 text-gray-800">{translation}</span>
              <% end %>
            </div>
          </div>
          <.button
            class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors mb-4"
            phx-value-id={@flash_card.id}
            phx-click="right_answer"
          >
            Right answer
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
