defmodule AtomicWordsWeb.HomeLive do
  use Phoenix.LiveView

  import AtomicWordsWeb.CoreComponents

  #alias AtomicWordsWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
      <div class="flex flex-row justify-left p-5">
        <div id="menu" class="mb-5" (style="margin-bottom: 20px;")>
          <ul>
            <li><button class="button" phx-click="go_to_settings">Go to Settings</button></li>
            <li><button class="button" phx-click="go_to_stats">Go to Stats</button></li>
            <li><button class="button" phx-click="words">Words</button></li>
          </ul>
        </div>

        <div class="flex-col justify-center" style="margin-left: 100px;">
          <div class="flex-row" style="position: relative;">
            <div id="form" class="mt-5" style="margin-bottom: 20px; position: relative;">
              <form class="add_word_form" style="display: flex; align-items: center;">
                <input class="add_word_input" type="text" id="search" name="search" placeholder="Type to search words..."/>
                <.icon name="hero-magnifying-glass" class="icon"/>
              </form>
            </div>

          </div>

          <div id="words-list" class="mt-5" style="margin-top: 20px;" >
            <h1>Words List</h1>
          </div>
        </div>
    </div>

    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

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
