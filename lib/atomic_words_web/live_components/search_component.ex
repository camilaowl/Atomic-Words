defmodule AtomicWordsWeb.LiveComponents.SearchComponent do
  use AtomicWordsWeb, :live_component

  import AtomicWordsWeb.CoreComponents
  alias AtomicWords.Words

  def render(assigns) do
    ~H"""
    <div class="flex-row" style="position: relative;">
      <div id="form" class="mt-5" style="margin-bottom: 20px; position: relative;">
        <form
          phx-change="change"
          phx-debounce="300"
          phx-target={@myself}
          class="add_word_form"
          role="search"
          style="display: flex; align-items: center;"
        >
          <input
            class="add_word_input"
            type="search"
            id="search"
            name="search"
            placeholder="Type to search words..."
          />
          <.icon name="hero-magnifying-glass" class="icon" />

          <datalist id="search-results-list">
            <option value="option 1"></option>
            <option value="option 2"></option>
            <option value="option 3"></option>
            <%= for search_result <- @search_results do %>
              <option style="" value={search_result.text} ({search_result.lang})></option>
            <% end %>
          </datalist>
        </form>
      </div>

      <h3 id="translation-result" class="mt-5" style="margin-top: 20px;">
        {@translation_result}
      </h3>
    </div>
    """
  end

  def mount(socket) do
    socket =
      socket
      |> assign(:search_results, [])

    {:ok, socket}
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, :search_results, [])
    {:noreply, socket}
  end

  def handle_event("change", %{"search" => %{"query" => search_query}}, socket) do
    if String.length(search_query) > 2 do
      search_results = Words.search_partial(search_query)
      socket = assign(socket, :search_results, search_results)
      {:noreply, socket}
    else
      socket = assign(socket, :search_results, [])
      {:noreply, socket}
    end
  end
end
