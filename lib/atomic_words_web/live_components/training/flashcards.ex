defmodule AtomicWordsWeb.LiveComponents.Training.Flashcards do
  use AtomicWordsWeb, :live_component

  attr :current_scope, :any, required: true
  attr :words, :list, default: []

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row w-full justify-center">
      <div class="w-1/2">
        <h1 class="text-3xl font-bold mb-4">Flashcards</h1>
        <div class="flex flex-col gap-4">
          <%= for word <- @words do %>
            <div class="flashcard p-4 bg-white rounded-lg shadow-md">
              <h2 class="text-xl font-bold">{word.word}</h2>
              <p class="text-gray-600">{word.us_transcription}</p>
              <div class="mt-2">
                <%= for translation <- word.translations do %>
                  <span class="mr-2 text-gray-800">{translation.text}</span>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
