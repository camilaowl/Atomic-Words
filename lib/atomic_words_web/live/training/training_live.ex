defmodule AtomicWordsWeb.TrainingLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Training

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:training}>
      <div class="flex flex-row justify-center w-full h-full my-5">
        <div class="flex flex-col justify-items-center">
          <div class=" basis-1/4 flex flex-row items-center justify-between w-full my-2 gap-x-2">
            <div class="flex rounded-lg outline outline-black/10 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 p-4">
              <h1 class="text-xl font-bold mb-4">My dictionary</h1>
            </div>
          </div>

          <div class=" basis-3/4 flex justify-center items-center w-full">
            <%= if @active_session do %>
              <.live_component
                module={AtomicWordsWeb.LiveComponents.Training.Flashcards}
                id="flashcards"
                current_scope={@current_scope}
                flash_card={@current_flash_card}
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
          <%= if @active_session do %>
            <button
              class="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors mb-4"
              phx-click="complete_training"
            >
              Complete Training
            </button>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    active_session = Training.active_session_for_user(socket.assigns.current_scope.user.id)

    cards =
      if active_session, do: Training.flashcards_for_session(active_session.id), else: []

    # current = Enum.find(cards, nil, &is_nil(&1.is_correct))
    # next_card = Enum.at(cards, Enum.find_index(cards, current) + 1)

    socket =
      socket
      |> assign(:active_session, active_session)
      |> assign(:current_flash_card, List.first(cards))

    # |> assign(:next_flash_card, next_card)

    {:ok, socket}
  end

  @impl true
  def handle_event("start_training", _params, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Training.start_training(user_id) do
      {:ok, session} ->
        [current, _] = Training.flashcards_for_session(session.id)

        socket =
          socket
          |> assign(:active_session, session)
          # |> assign(:flash_cards, flash_cards)
          |> assign(:current_flash_card, current)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("complete_training", _params, socket) do
    session_id = socket.assigns.active_session.id
    user_id = socket.assigns.current_scope.user.id

    case Training.complete_training(session_id, user_id) do
      {:ok, _session} ->
        socket =
          socket
          |> assign(:active_session, nil)
          # |> assign(:flash_cards, [])
          |> assign(:current_flash_card, nil)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("wrong_answer", %{"id" => id}, socket) do
    Training.flash_card_answer(id, false)
    {:noreply, socket}
  end

  @impl true
  def handle_event("right_answer", %{"id" => id}, socket) do
    Training.flash_card_answer(id, true)
    {:noreply, socket}
  end
end
