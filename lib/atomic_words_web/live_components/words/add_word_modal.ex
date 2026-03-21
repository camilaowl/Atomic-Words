defmodule AtomicWordsWeb.LiveComponents.Words.AddWordModal do
  use AtomicWordsWeb, :live_component

  alias AtomicWords.Dictionary
  attr :current_scope, :any, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="edit-modal"
      class="fixed inset-0 z-50 flex items-center justify-center"
      phx-window-keydown="close_edit_modal"
      phx-key="escape"
    >
      <div class="absolute inset-0 bg-black/40" phx-click="close_edit_modal"></div>
      <div class="relative z-10 w-full max-w-xl rounded-xl bg-white p-6 shadow-xl">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold">Edit word</h2>
          <button type="button" phx-click="close_edit_modal">
            <.icon name="hero-x-mark" class="w-5 h-5" />
          </button>
        </div>
        <!-- form goes here -->
      </div>
    </div>
    """
  end
end
