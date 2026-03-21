defmodule AtomicWordsWeb.WordsLive do
  alias AtomicWords.Dictionary
  use AtomicWordsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      current_scope={@current_scope}
      flash={@flash}
      active_tab={:words}
      active_session={@active_session}
    >
      <div class="flex flex-col items-center justify-center gap-y-6">
        <%= if Enum.empty?(@words) do %>
          <div class="flex flex-col items-center justify-center gap-2 p-4 mt-12">
            <p class="text-gray-500 text-lg">
              No words yet
            </p>
            <p class="text-gray-500 text-lg">
              Add your first word!
            </p>
            <.button
              variant="primary"
              phx-click="add_word"
              class="bg-green-500 hover:bg-green-600 text-white border-0 h-auto mt-4"
            >
              Add word
            </.button>
          </div>
        <% else %>
          <div
            id="form"
            class="related w-1/2 h-fit rounded-lg p-1 outline outline-black/5 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 "
          >
            <form
              phx-change="change"
              phx-debounce="300"
              class="flex flex-row items-center gap-1 w-full"
              role="search"
            >
              <input
                class=" px-4 w-full placeholder:italic display:inline bg-transparent focus:outline-none"
                type="search"
                id="search"
                name="search"
                placeholder="Search in my dictionary..."
                phx-debounce="300"
              />
              <button
                type="button"
                aria-label="Clear search"
                phx-click="clear_search"
                class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors flex items-center justify-center"
              >
                <.icon name="hero-x-mark" class="w-5 h-5 text-gray-600 dark:text-gray-300" />
              </button>
            </form>
          </div>
          <div class="w-1/2 flex flex-row">
            <div id="filter" class="w-fit h-fit flex flex-row gap-x-2">
              <span
                phx-click="filter"
                phx-value-filter="all"
                class={[
                  "mr-4 border-1 border-orange-500 rounded-lg p-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors",
                  @selected_filter == :all && "bg-orange-500 text-white"
                ]}
              >
                All
              </span>
              <span
                phx-click="filter"
                phx-value-filter="new"
                class={[
                  "mr-4 border-1 border-orange-500 rounded-lg p-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors",
                  @selected_filter == :new && "bg-orange-500 text-white"
                ]}
              >
                New
              </span>
              <span
                phx-click="filter"
                phx-value-filter="difficult"
                class={[
                  "mr-4 border-1 border-orange-500 rounded-lg p-2 cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors",
                  @selected_filter == :difficult && "bg-orange-500 text-white"
                ]}
              >
                Difficult
              </span>
            </div>
            <.button
              variant="primary"
              phx-click="add_word"
              class="right-0 bg-green-500 hover:bg-green-600 ml-auto text-white border-0 h-auto"
            >
              Add word
            </.button>
          </div>
          <%= if @show_add_word_modal do %>
            <.live_component
              module={AtomicWordsWeb.LiveComponents.Words.AddWordModal}
              id="add-word-modal"
              current_scope={@current_scope}
            />
          <% end %>
          <div id="words-list" class="w-1/2">
            <.live_component
              module={AtomicWordsWeb.LiveComponents.Words.WordList}
              id="words"
              words={@words}
              current_scope={@current_scope}
            />
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    words = Dictionary.user_words(user_id)

    socket =
      socket
      |> assign(:words, words)
      |> assign(:selected_filter, :all)
      |> assign(:show_add_word_modal, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("change", %{"search" => ""}, socket) do
    user_id = socket.assigns.current_scope.user.id
    words = Dictionary.user_words(user_id)
    socket = assign(socket, :words, words)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change", %{"search" => search_query}, socket) do
    if String.length(search_query) > 2 do
      user_id = socket.assigns.current_scope.user.id

      search_results =
        Dictionary.search_partial_in_user_words(search_query, user_id)

      socket = assign(socket, :words, search_results)
      {:noreply, socket}
    else
      socket = assign(socket, :words, [])
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_word", _params, socket) do
    socket = assign(socket, :show_add_word_modal, true)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_search", _params, socket) do
    user_id = socket.assigns.current_scope.user.id
    words = Dictionary.user_words(user_id)

    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:words, words)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter_value}, socket) do
    user_id = socket.assigns.current_scope.user.id

    {selected_filter, words} =
      case filter_value do
        "new" -> {:new, Dictionary.user_words(user_id)}
        "difficult" -> {:difficult, Dictionary.user_words(user_id)}
        _ -> {:all, Dictionary.user_words(user_id)}
      end

    {:noreply, assign(socket, selected_filter: selected_filter, words: words)}
  end

  @impl true
  def handle_info({:word_deleted, _id}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope
    words = Dictionary.user_words(user_id)

    socket = assign(socket, :words, words)

    {:noreply, socket}
  end
end
