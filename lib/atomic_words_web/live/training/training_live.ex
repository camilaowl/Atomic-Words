defmodule AtomicWordsWeb.TrainingLive do
  alias AtomicWords.Dictionary
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Words

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:training}>
      <div class="flex flex-row justify-center size-full my-5">
        <div class="flex-col justify-center w-1/2">
          <div class="flex flex-row items-center justify-between w-full my-2 gap-x-2">
            <div class="flex rounded-lg outline outline-black/10 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 p-4">
              <h1 class="text-xl font-bold mb-4">My dictionary</h1>
            </div>
          </div>

          <div class="flex justify-center items-center w-full h-2/3">
            <%= if @active_session do %>
              <.live_component
                module={AtomicWordsWeb.LiveComponents.Training.Flashcards}
                id="flashcards"
                current_scope={@current_scope}
                words={@words}
              />
            <% else %>
              <button
                class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors mb-4"
                phx-click="start_training"
              >
                Start Training
              </button>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    words = Dictionary.user_words(socket.assigns.current_scope.user.id)

    socket =
      socket
      |> assign(:words, words)
      |> assign(:active_session, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("start_training", _params, socket) do
    {:noreply, socket}
  end
end
