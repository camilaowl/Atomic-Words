defmodule AtomicWordsWeb.TrainingModeLive do
  use AtomicWordsWeb, :live_view
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:training}>
      <div class="flex flex-col items-left w-full h-full gap-6 p-6">
        <h2 class="text-2xl font-bold ">Training Modes:</h2>
        <div class=" flex flex-row items-center my-2 gap-x-2">
          <.live_component
            module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
            id="training-mode-my-words"
            current_scope={@current_scope}
            mode_name="My words"
            ,
            mode_value="my_words"
          />
          <.live_component
            module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
            id="training-mode-difficult"
            current_scope={@current_scope}
            mode_name="Difficult words"
            ,
            mode_value="difficult"
          />

          <.live_component
            module={AtomicWordsWeb.LiveComponents.Training.TrainingMode}
            id="training-mode-random"
            current_scope={@current_scope}
            mode_name="Random"
            ,
            mode_value="random"
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_event(<<_::88>>, any(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("start_training", value, socket) do
    mode = value["mode"] || "my_words"
    limit = value["limit"] || "15"
    {:noreply, push_navigate(socket, to: ~p"/training?#{%{mode: mode, limit: limit}}")}
  end
end
