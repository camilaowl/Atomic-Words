defmodule AtomicWordsWeb.WordsLive do
  use AtomicWordsWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:words}>
      <div class="flex flex-row justify-center w-full">
        <p class="text-center text-xl">Words Live View</p>
      </div>
    </Layouts.app>
    """
  end
end
