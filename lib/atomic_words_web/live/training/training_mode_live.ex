defmodule AtomicWordsWeb.Training.TrainingModeLive do
  use AtomicWordsWeb, :live_view
  alias AtomicWords.Training

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash} active_tab={:training}>
      <div class=" basis-1/4 flex flex-wrap items-center justify-between w-full my-2 gap-x-2">
        <div class="flex rounded-lg outline outline-black/10 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 p-4">
          <h1 class="text-xl font-bold mb-4">My dictionary</h1>
        </div>

        <div class="flex rounded-lg outline outline-black/10 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 p-4">
          <h1 class="text-xl font-bold mb-4">My dictionary</h1>
        </div>

        <div class="flex rounded-lg outline outline-black/10 dark:bg-grey-600 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5 p-4">
          <h1 class="text-xl font-bold mb-4">My dictionary</h1>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
