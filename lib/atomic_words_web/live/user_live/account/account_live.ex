defmodule AtomicWordsWeb.AccountLive do
  use AtomicWordsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.page
      flash={@flash}
      current_scope={@current_scope}
      page_name="Account"
      back_path={~p"/"}
    >
      <div class="mx-auto flex max-w-3xl flex-col gap-6 px-6 py-8">
        <div class="space-y-2">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Account</h1>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            This page is a placeholder for future account management screens.
          </p>
        </div>

        <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
          <p class="text-sm text-gray-600 dark:text-gray-300">
            Account changes will move here in a future update.
          </p>
          <.link navigate={~p"/settings"} class="mt-4 inline-flex text-sm font-medium text-blue-600">
            Back to settings
          </.link>
        </div>
      </div>
    </Layouts.page>
    """
  end
end
