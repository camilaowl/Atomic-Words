defmodule AtomicWordsWeb.LiveComponents.Training.TrainingMode do
  use AtomicWordsWeb, :live_component

  attr :current_scope, :any, required: true
  attr :mode_name, :string, required: true
  attr :mode_value, :string, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-72 h-48 rounded-lg bg-white shadow-md flex flex-col items-center justify-center">
      <h2 class="text-xl font-bold">{@mode_name}</h2>
      <div class="flex flex-row justify-items-stretch gap-4">
        <button
          class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-blue-600 transition-colors mb-4"
          phx-click="start_training"
          phx-value-mode={@mode_value}
          phx-value-limit="15"
        >
          15
        </button>

        <button
          class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-blue-600 transition-colors mb-4"
          phx-click="start_training"
          phx-value-mode={@mode_value}
          phx-value-limit="30"
        >
          30
        </button>

        <button
          class="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-blue-600 transition-colors mb-4"
          phx-click="start_training"
          phx-value-mode={@mode_value}
          phx-value-limit="all"
        >
          All
        </button>
      </div>
    </div>
    """
  end
end
