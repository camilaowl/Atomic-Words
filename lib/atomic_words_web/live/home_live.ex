defmodule AtomicWordsWeb.HomeLive do
  use AtomicWordsWeb, :live_view

  # import AtomicWordsWeb.CoreComponents
  alias AtomicWords.Dictionary

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      current_scope={@current_scope}
      flash={@flash}
      active_tab={:home}
      active_session={@active_session}
    >
      <div class="w-1/2 mx-auto">
        <.live_component
          module={AtomicWordsWeb.LiveComponents.SearchComponent}
          id="search"
          current_scope={@current_scope}
        />

        <div id="words-list" class="mt-5">
          <h1>The last added:</h1>
          <.live_component
            module={AtomicWordsWeb.LiveComponents.Words.WordList}
            id="last-added"
            words={@last_added}
            current_scope={@current_scope}
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope

    last_added = Dictionary.last_added_user_words(user_id)

    socket =
      socket
      |> assign(:last_added, last_added)

    {:ok, socket}
  end

  @impl true
  def handle_info({:word_added, _added_word}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope
    last_added = Dictionary.last_added_user_words(user_id)

    socket =
      socket
      |> assign(:last_added, last_added)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:word_deleted, _id}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope
    last_added = Dictionary.last_added_user_words(user_id)

    socket = assign(socket, :last_added, last_added)

    {:noreply, socket}
  end
end
