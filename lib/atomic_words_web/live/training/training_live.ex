defmodule AtomicWordsWeb.TrainingLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Training

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:training}>
      <div class="flex flex-col items-center justify-center w-full my-5">
        <div class="w-full max-w-3xl ">
          <div class="flex flex-row items-center gap-4 w-full">
            <%= cond do %>
              <% @active_session -> %>
                <div class="flex flex-row gap-1 items-center justify-center shrink-0">
                  <.icon name="hero-chevron-left" class="w-12 h-12 text-red-600" />
                  <div class="flex flex-col items-center justify-center">
                    <p class="text-sm font-bold text-red-600">Swipe left</p>
                    <p class="text-sm font-medium text-red-600">if you were wrong</p>
                  </div>
                </div>
                <div class="flex-1 min-w-0">
                  <.live_component
                    module={AtomicWordsWeb.LiveComponents.Training.Flashcards}
                    id="flashcards"
                    current_scope={@current_scope}
                    flash_card={@current_flash_card}
                    next_flash_card={@next_flash_card}
                  />
                </div>
                <div class="flex flex-row gap-1 items-center justify-left shrink-0">
                  <div class="flex flex-col items-center justify-center">
                    <p class="text-sm font-bold text-green-600">Swipe right</p>
                    <p class="text-sm font-medium text-green-600">if you were right</p>
                  </div>

                  <.icon name="hero-chevron-right" class="w-12 h-12 text-green-600" />
                </div>
              <% @training_finished -> %>
                <div class="text-center">
                  <h2 class="text-2xl font-bold mb-4">No more flashcards to review!</h2>
                  <p class="text-gray-600 mb-6">You've completed all flashcards for this session.</p>
                </div>
              <% true -> %>
                <div class="flex justify-center w-full">
                  <button
                    class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors mb-4"
                    phx-click="start_training"
                  >
                    Start Training
                  </button>
                </div>
            <% end %>
          </div>
          <%= if @active_session do %>
            <div class="flex justify-center mt-12">
              <button
                class="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
                phx-click="complete_training"
              >
                Complete Training
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    active_session = Training.active_session_for_user(socket.assigns.current_scope.user.id)

    if connected?(socket) do
      user_id = socket.assigns.current_scope.user.id
      Phoenix.PubSub.subscribe(AtomicWords.PubSub, "training:#{user_id}")
    end

    socket =
      socket
      |> assign(:active_session, active_session)
      |> assign(:training_finished, false)
      |> assign_current_and_next_flash_cards()

    {:ok, socket}
  end

  @impl true
  def handle_event("start_training", _params, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Training.start_training(user_id) do
      {:ok, session} ->
        socket =
          socket
          |> assign(:active_session, session)
          |> assign_current_and_next_flash_cards()

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:training_finished, _}, socket) do
    {:noreply, assign(socket, :training_finished, true)}
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
          |> assign(:current_flash_card, nil)
          |> assign(:next_flash_card, nil)

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("wrong_answer", %{"id" => id}, socket) do
    Training.flash_card_answer(id, false)

    {:noreply, assign_current_and_next_flash_cards(socket)}
  end

  @impl true
  def handle_event("right_answer", %{"id" => id}, socket) do
    Training.flash_card_answer(id, true)

    {:noreply, assign_current_and_next_flash_cards(socket)}
  end

  defp assign_current_and_next_flash_cards(socket) do
    case socket.assigns.active_session do
      nil ->
        socket
        |> assign(:current_flash_card, nil)
        |> assign(:next_flash_card, nil)

      active_session ->
        user_id = socket.assigns.current_scope.user.id
        {current_card, next_card} = Training.current_and_next_flash_cards(active_session.id)

        if is_nil(current_card) do
          {:ok, _} = Training.complete_training(active_session.id, user_id)

          Phoenix.PubSub.broadcast(
            AtomicWords.PubSub,
            "training:#{user_id}",
            {:training_finished, active_session.id}
          )

          socket
          |> assign(:active_session, nil)
          |> assign(:current_flash_card, nil)
          |> assign(:next_flash_card, nil)
        else
          socket
          |> assign(:current_flash_card, current_card)
          |> assign(:next_flash_card, next_card)
        end
    end
  end
end
