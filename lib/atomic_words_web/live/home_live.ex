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
                  <li>{word.text} ({word.lang})</li>
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

  def mount(%{"search" => word}, _session, socket) do
    translation_result =
      case AtomicWords.Translator.translate(word, "uk") do
        {:ok, translated_text} -> translated_text
        {:error, _reason} -> "Translation error"
      end

    %{user: %{id: user_id}} = socket.assigns.current_scope

    # todo replace with current user id
    last_added = Words.last_added_user_words(user_id, 30)

    socket =
      socket
      |> assign(:translation_result, translation_result)
      |> assign(:last_added, last_added)

    {:ok, socket}
  end

  def mount(_params, session, socket), do: mount(%{"search" => ""}, session, socket)
end
