defmodule AtomicWordsWeb.AccountPasswordLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.page flash={@flash} page_name="Change password" back_path={~p"/account"}>
      <div class="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-8">
        <div class="space-y-2">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Change password</h1>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Enter your current password first, then choose a new one.
          </p>
        </div>

        <section class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
          <.form
            for={@password_form}
            id="account-password-edit-form"
            action={~p"/account/password"}
            method="put"
            phx-change="validate_password"
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              type="password"
              name="user[current_password]"
              id="account-password-current-password"
              value={@current_password}
              label="Current password"
              errors={@current_password_errors}
            />
            <.input field={@password_form[:password]} type="password" label="New password" />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />

            <div class="mt-4 flex justify-end gap-3">
              <.link
                navigate={~p"/account"}
                class="inline-flex items-center justify-center rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-600 transition hover:bg-gray-50"
              >
                Cancel
              </.link>
              <.button>Save</.button>
            </div>
          </.form>
        </section>
      </div>
    </Layouts.page>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_password, "")
     |> assign(:current_password_errors, [])
     |> assign(:trigger_submit, false)
     |> assign(:password_form, password_form(socket.assigns.current_scope.user))}
  end

  @impl true
  def handle_event("validate_password", %{"user" => user_params}, socket) do
    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     socket
     |> assign(:trigger_submit, false)
     |> assign(:password_form, password_form)
     |> assign(:current_password, Map.get(user_params, "current_password", ""))
     |> assign(:current_password_errors, [])}
  end

  def handle_event("submit_password", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    current_password = Map.get(user_params, "current_password", "")
    password_changeset = Accounts.change_user_password(user, user_params, hash_password: false)

    cond do
      not Accounts.valid_user_password?(user, current_password) ->
        {:noreply,
         socket
         |> assign(:trigger_submit, false)
         |> assign(:password_form, to_form(Map.put(password_changeset, :action, :validate)))
         |> assign(:current_password, "")
         |> assign(:current_password_errors, ["is not correct"])}

      password_changeset.valid? ->
        {:noreply,
         socket
         |> assign(:trigger_submit, true)
         |> assign(:password_form, to_form(password_changeset))
         |> assign(:current_password, current_password)
         |> assign(:current_password_errors, [])}

      true ->
        {:noreply,
         socket
         |> assign(:trigger_submit, false)
         |> assign(:password_form, to_form(Map.put(password_changeset, :action, :insert)))
         |> assign(:current_password, current_password)
         |> assign(:current_password_errors, [])}
    end
  end

  defp password_form(user) do
    user
    |> Accounts.change_user_password(%{}, hash_password: false)
    |> to_form()
  end
end
