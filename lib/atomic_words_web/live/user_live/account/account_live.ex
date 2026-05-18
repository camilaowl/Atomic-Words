defmodule AtomicWordsWeb.AccountLive do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Accounts
  alias AtomicWords.Accounts.Scope
  alias AtomicWordsWeb.AccountComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      active_tab={:account}
      active_session={@active_session}
    >
      <div class="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-8">
        <h1 class="text-3xl font-semibold tracking-tight text-slate-900 dark:text-white">
          Account
        </h1>

        <AccountComponents.profile_section
          user={@current_scope.user}
          avatar_url={@avatar_url}
          editing_nickname={@editing_nickname}
          nickname_form={@nickname_form}
        />

        <AccountComponents.security_section email={@current_scope.user.email} />

        <AccountComponents.session_section />

        <AccountComponents.remove_account_section expanded={@show_remove_account_details} />

        <AccountComponents.delete_account_modal
          show={@show_delete_modal}
          form={@delete_account_form}
          delete_password={@delete_password}
          delete_password_errors={@delete_password_errors}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_account(socket)}
  end

  @impl true
  def handle_event("avatar_unavailable", _params, socket) do
    {:noreply, put_flash(socket, :info, "Avatar editing is not available yet.")}
  end

  def handle_event("toggle_nickname_edit", _params, socket) do
    user = socket.assigns.current_scope.user

    {:noreply,
     socket
     |> assign(:editing_nickname, true)
     |> assign(:nickname_form, nickname_form(user))}
  end

  def handle_event("cancel_nickname_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_nickname, false)
     |> assign(:nickname_form, nickname_form(socket.assigns.current_scope.user))}
  end

  def handle_event("validate_nickname", %{"user" => user_params}, socket) do
    nickname_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_nickname(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :nickname_form, nickname_form)}
  end

  def handle_event("update_nickname", %{"user" => user_params}, socket) do
    current_user = socket.assigns.current_scope.user

    case Accounts.update_user_nickname(current_user, user_params) do
      {:ok, user} ->
        updated_user = %{user | authenticated_at: current_user.authenticated_at}

        {:noreply,
         socket
         |> assign(:current_scope, Scope.for_user(updated_user))
         |> assign(:editing_nickname, false)
         |> assign(:nickname_form, nickname_form(updated_user))
         |> put_flash(:info, "Nickname updated successfully.")}

      {:error, changeset} ->
        {:noreply, assign(socket, :nickname_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("open_delete_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_delete_modal, true)
     |> assign(:delete_password, "")
     |> assign(:delete_password_errors, [])}
  end

  def handle_event("toggle_remove_account_details", _params, socket) do
    {:noreply, update(socket, :show_remove_account_details, &(!&1))}
  end

  def handle_event("close_delete_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_delete_modal, false)
     |> assign(:delete_password, "")
     |> assign(:delete_password_errors, [])}
  end

  def handle_event("confirm_delete_account", %{"delete_account" => params}, socket) do
    user = socket.assigns.current_scope.user
    password = Map.get(params, "password", "")

    if Accounts.valid_user_password?(user, password) do
      {:noreply,
       socket
       |> assign(:show_delete_modal, false)
       |> assign(:delete_password, "")
       |> assign(:delete_password_errors, [])
       |> put_flash(:info, "Delete-account logic is not implemented yet.")}
    else
      {:noreply,
       socket
       |> assign(:delete_password, "")
       |> assign(:delete_password_errors, ["is not correct"])}
    end
  end

  defp assign_account(socket) do
    user = socket.assigns.current_scope.user

    socket
    |> assign(:avatar_url, nil)
    |> assign(:editing_nickname, false)
    |> assign(:show_remove_account_details, false)
    |> assign(:show_delete_modal, false)
    |> assign(:delete_password, "")
    |> assign(:delete_password_errors, [])
    |> assign(:delete_account_form, to_form(%{}, as: :delete_account))
    |> assign(:nickname_form, nickname_form(user))
  end

  defp nickname_form(user) do
    user
    |> Accounts.change_user_nickname(%{})
    |> to_form()
  end
end
