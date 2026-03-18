defmodule AtomicWordsWeb.TrainingModeLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Training
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      current_scope={@current_scope}
      flash={@flash}
      active_tab={:training}
      active_session={@active_session}
    >
      <div class="w-full h-full flex flex-col items-center justify-center">
        <div class="flex flex-col items-left w-full h-full gap-6 p-6">
          <h2 class="text-2xl font-bold ">Choose Training Mode:</h2>
          <div class=" flex flex-row items-center my-2 gap-x-2">
            <.live_component
              module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
              id="training-mode-my-words"
              current_scope={@current_scope}
              mode_name="My words"
              mode_value="my_words"
              limits={[15, 30, "all"]}
            />
            <.live_component
              module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
              id="training-mode-difficult"
              current_scope={@current_scope}
              mode_name="Difficult words"
              mode_value="difficult"
              limits={[15, 30, 45]}
            />

            <.live_component
              module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
              id="training-mode-random"
              current_scope={@current_scope}
              mode_name="Random"
              mode_value="random"
              limits={[15, 30, 45]}
            />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    active_session = Training.active_session_for_user(user_id)

    socket =
      socket
      |> assign(:active_session, active_session)

    {:ok, socket}
  end

  @impl true
  def handle_event("start_training", value, socket) do
    user_id = socket.assigns.current_scope.user.id
    mode = value["mode"] || "my_words"
    limit = value["limit"] || 15

    # need to abandon active session if it exists. need to add "abandon"
    # functionality and a field to db table to mark session as abandoned.
    # for now, just automatically mark the old one as completed

    Training.abandon_active_session(user_id)

    case Training.start_training_with_mode(mode, limit, user_id) do
      {:ok, session} ->
        socket =
          socket
          |> assign(:active_session, session)

        {:noreply, push_navigate(socket, to: ~p"/training?#{%{session_id: session.id}}")}

      {:error, _changeset} ->
        {:noreply, assign(socket, :active_session, nil)}
    end
  end
end
