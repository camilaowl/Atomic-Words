defmodule AtomicWordsWeb.AccountEmailLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.page flash={@flash} page_name="Change email" back_path={~p"/account"}>
      <div class="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-8">
        <div class="space-y-2">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white">Change email</h1>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Enter your current password to save a new email address.
          </p>
        </div>

        <section class="flex flex-col gap-6 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
          <div class="flex flex-col gap-1">
            <p class="text-base font-semibold text-gray-900 dark:text-white">Current email</p>
            <p class="text-sm text-gray-500 dark:text-gray-400">{@current_scope.user.email}</p>
          </div>

          <.form
            for={@email_form}
            id="account-email-edit-form"
            phx-change="validate_email"
            phx-submit="update_email"
          >
            <.input field={@email_form[:email]} type="email" label="New email" />
            <.input
              type="password"
              name="user[current_password]"
              id="account-email-current-password"
              value={@current_password}
              label="Current password"
              errors={@current_password_errors}
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
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/account")}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_password, "")
     |> assign(:current_password_errors, [])
     |> assign(:email_form, email_form(socket.assigns.current_scope.user))}
  end

  @impl true
  def handle_event("validate_email", %{"user" => user_params}, socket) do
    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(Map.take(user_params, ["email"]), validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     socket
     |> assign(:email_form, email_form)
     |> assign(:current_password, Map.get(user_params, "current_password", ""))
     |> assign(:current_password_errors, [])}
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    current_password = Map.get(user_params, "current_password", "")
    email_params = Map.take(user_params, ["email"])

    cond do
      not Accounts.valid_user_password?(user, current_password) ->
        {:noreply,
         socket
         |> assign(
           :email_form,
           to_form(Accounts.change_user_email(user, email_params, validate_unique: false),
             action: :validate
           )
         )
         |> assign(:current_password, "")
         |> assign(:current_password_errors, ["is not correct"])}

      true ->
        case Accounts.update_user_email(user, email_params) do
          {:ok, _updated_user} ->
            {:noreply,
             socket
             |> put_flash(:info, "Email updated successfully.")
             |> push_navigate(to: ~p"/account")}

          {:error, changeset} ->
            {:noreply,
             socket
             |> assign(:email_form, to_form(changeset, action: :insert))
             |> assign(:current_password, "")
             |> assign(:current_password_errors, [])}
        end
    end
  end

  defp email_form(user) do
    user
    |> Accounts.change_user_email(%{}, validate_unique: false)
    |> to_form()
  end
end
