defmodule AtomicWordsWeb.HomeLive do
  use Phoenix.LiveView

  #alias AtomicWordsWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    <h1>Home</h1>
    <button phx-click="go_to_settings">Go to Settings</button>
    <button phx-click="go_to_stats">Go to Stats</button>
    <button phx-click="words">Words</button>
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
