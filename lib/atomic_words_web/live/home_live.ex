defmodule AtomicWordsWeb.HomeLive do
  use AtomicWordsWeb, :live_view

  # import AtomicWordsWeb.CoreComponents
  alias AtomicWords.Words

  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:home}>
      <div class="flex flex-row justify-center w-full">
        <div class="flex-col justify-center w-1/2">
          <.live_component
            module={AtomicWordsWeb.LiveComponents.SearchComponent}
            id="search"
            current_scope={@current_scope}
            translation_result={@translation_result}
          />

          <div id="words-list" class="mt-5" style="margin-top: 20px;">
            <h1>The last added:</h1>
            <ul class="pt-4">
              <%= for word <- @last_added do %>
                <section>
                  <WordListItem.word_list_item word={word} translation={word} />
                </section>
              <% end %>
            </ul>
          </div>
        </div>
        <div id="spacer" class="w-1/4" />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"search" => word}, _session, socket) do
    translation_result =
      case AtomicWords.Translator.translate(word, "uk") do
        {:ok, translated_text} -> translated_text
        {:error, _reason} -> "Translation error"
      end

    %{user: %{id: user_id}} = socket.assigns.current_scope

    last_added = Words.last_added_user_words(user_id)

    socket =
      socket
      |> assign(:translation_result, translation_result)
      |> assign(:last_added, last_added)

    {:ok, socket}
  end

  @impl true
  def mount(_params, session, socket), do: mount(%{"search" => ""}, session, socket)

  @impl true
  def handle_info({:word_added, _added_word}, socket) do
    %{user: %{id: user_id}} = socket.assigns.current_scope
    last_added = Words.last_added_user_words(user_id)

    socket =
      socket
      |> assign(:last_added, last_added)

    {:noreply, socket}
  end
end
