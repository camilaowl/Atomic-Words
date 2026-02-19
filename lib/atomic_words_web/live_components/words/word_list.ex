defmodule AtomicWordsWeb.LiveComponents.Words.WordList do
  use AtomicWordsWeb, :live_component

  alias AtomicWords.Words
  attr :words, :list, default: []
  attr :current_scope, :any, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <%= for word <- @words do %>
        <WordListItem.word_list_item
          word={word}
          target={@myself}
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("delete_word", %{"id" => id}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope
    Words.delete_user_word_by_id(user_id, id)
    send(self(), {:word_deleted, id})
    {:noreply, socket}
  end
end
