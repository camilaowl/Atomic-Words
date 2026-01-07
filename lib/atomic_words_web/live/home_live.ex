defmodule AtomicWordsWeb.HomeLive do
  use AtomicWordsWeb, :live_view

  # import AtomicWordsWeb.CoreComponents
  alias AtomicWords.Words

  def render(assigns) do
    ~H"""
    <div class="flex flex-row justify-center w-full">
      <div id="menu" class="flex flex-col w-1/4">
        <ul>
          <.link navigate={~p"/settings"}>
            Go to Settings
          </.link>
          <li><button class="button" phx-click="go_to_settings">Go to Settings</button></li>
          <li><button class="button" phx-click="go_to_stats">Go to Stats</button></li>
          <li><button class="button" phx-click="words">Words</button></li>
        </ul>
      </div>

      <div class="flex-col justify-center w-1/2">
        <.live_component
          module={AtomicWordsWeb.LiveComponents.SearchComponent}
          id="search"
          translation_result={@translation_result}
        />

        <div id="words-list" class="mt-5" style="margin-top: 20px;">
          <h1>The last added:</h1>
          <ul class="pt-4">
            <%= for word <- @last_added do %>
              <section>
                <li>{word.text} ({word.lang})</li>
              </section>
            <% end %>
          </ul>
        </div>
      </div>
      <div id="spacer" class="w-1/4" />
    </div>
    """
  end

  def mount(%{"search" => word}, _session, socket) do
    translation_result =
      case AtomicWords.Translator.translate(word, "uk") do
        {:ok, translated_text} -> translated_text
        {:error, _reason} -> "Translation error"
      end

    last_added = Words.last_added_user_words(1, 30)

    socket =
      socket
      |> assign(:translation_result, translation_result)
      |> assign(:last_added, last_added)

    {:ok, socket}
  end

  def mount(_params, session, socket), do: mount(%{"search" => ""}, session, socket)

  def handle_event("go_to_settings", _value, socket) do
    {:noreply, push_navigate(socket, to: "/settings")}
  end

  def handle_event("go_to_stats", _value, socket) do
    {:noreply, push_navigate(socket, to: "/stats")}
  end

  def handle_event("words", _value, socket) do
    {:noreply, push_navigate(socket, to: "/words")}
  end
end
