defmodule AtomicWordsWeb.Training.ActiveSessionBubble do
  use AtomicWordsWeb, :live_component

  attr :session_id, :integer, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-3 rounded-full px-4 py-2 shadow-lg border border-amber-50">
      <div class="flex items-center gap-2 text-sm text-amber-900">
        <.icon name="hero-fire" class="size-6" />
        <span class="font-large">You have an unfinished training session.</span>
      </div>
      <.button
        id="continue-training"
        navigate={~p"/training?session_id=#{@session_id}"}
        class="btn btn-primary btn-soft rounded-full btn-md"
      >
        Continue
      </.button>
    </div>
    """
  end
end
