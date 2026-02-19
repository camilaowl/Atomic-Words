defmodule AtomicWordsWeb.LiveComponents.SearchComponent do
  use AtomicWordsWeb, :live_component

  import AtomicWordsWeb.CoreComponents
  alias AtomicWords.Words

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col relative w-full">
      <div class="flex flex-row items-center justify-between w-full my-2 gap-x-2">
        <LangSwither.lang_swither
          origin_lang={@origin_lang}
          target_lang={@target_lang}
          phx-click="switch_languages"
          phx-target={@myself}
        />

        <div
          id="form"
          class="relative w-full rounded-lg outline outline-black/5 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 "
        >
          <form
            phx-change="change"
            phx-debounce="300"
            phx-target={@myself}
            class="flex flex-row items-center gap-1 w-full"
            role="search"
          >
            <input
              class=" px-4 w-full placeholder:italic display:inline bg-transparent focus:outline-none"
              type="search"
              id="search"
              name="search"
              placeholder="Type to search words..."
              phx-debounce="300"
            />
            <button
              type="button"
              aria-label="Clear search"
              phx-click="clear_search"
              phx-target={@myself}
              class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors flex items-center justify-center"
            >
              <.icon name="hero-x-mark" class="w-5 h-5 text-gray-600 dark:text-gray-300" />
            </button>
          </form>
        </div>
      </div>

      <%= if Enum.empty?(@search_results) do %>
        <p class="text-sm text-gray-500">No results</p>
      <% else %>
        <datalist
          id="search-results-list"
          class="card flex flex-col rounded-lg shadow-lg w-full bg-blue"
        >
          <%= for search_result <- @search_results do %>
            <SearchItem.search_item
              item={search_result}
              added={MapSet.member?(@added_word_ids, search_result.id)}
              phx-click="add_item"
              phx-target={@myself}
            />
          <% end %>
        </datalist>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:search_results, [])
      |> assign(:origin_lang, "en")
      |> assign(:target_lang, "uk")

    {:ok, socket}
  end

  @impl true
  def update(%{current_scope: %{user: %{id: user_id}}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:added_word_ids, load_added_word_ids(user_id))

    {:ok, socket}
  end

  @impl true
  def handle_event("change", %{"search" => ""}, socket) do
    socket = assign(socket, :search_results, [])
    {:noreply, socket}
  end

  @impl true
  def handle_event("change", %{"search" => search_query}, socket) do
    if String.length(search_query) > 2 do
      search_results =
        Words.search_partial(search_query, socket.assigns.origin_lang, socket.assigns.target_lang)

      socket = assign(socket, :search_results, search_results)
      {:noreply, socket}
    else
      socket = assign(socket, :search_results, [])
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("clear_search", _params, socket) do
    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:search_results, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_item", %{"id" => item_id}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope

    reply_socket =
      case Integer.parse(item_id) do
        {int, _rest} ->
          case Words.add_user_word(user_id, int) do
            {:ok, added_word} ->
              socket = assign(socket, :added_word_ids, load_added_word_ids(user_id))
              send(self(), {:word_added, added_word})
              socket

            {:error, _changeset} ->
              socket
          end

        :error ->
          socket
      end

    {:noreply, reply_socket}
  end

  @impl true
  def handle_event("switch_languages", _params, socket) do
    origin_lang = socket.assigns.origin_lang
    target_lang = socket.assigns.target_lang

    socket =
      socket
      |> assign(:origin_lang, target_lang)
      |> assign(:target_lang, origin_lang)

    {:noreply, socket}
  end

  defp load_added_word_ids(user_id) do
    user_id
    |> Words.find_user_words_by_user_id()
    |> Enum.map(& &1.word_id)
    |> MapSet.new()
  end
end
