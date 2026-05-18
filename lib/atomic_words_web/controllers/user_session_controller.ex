defmodule AtomicWordsWeb.UserSessionController do
  use AtomicWordsWeb, :controller

  alias AtomicWords.Accounts
  alias AtomicWordsWeb.UserAuth
  alias AtomicWords.Accounts.User

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "User confirmed successfully.")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  # auto log in after registration
  def auto_login(conn, %{"token" => token}) do
    with {:ok, user_id} <-
           Phoenix.Token.verify(AtomicWordsWeb.Endpoint, "auto_login", token, max_age: 600),
         %User{} = user <- Accounts.get_user!(user_id) do
      conn
      |> put_flash(:info, "Account created successfully.")
      |> UserAuth.log_in_user(user)
    else
      _ ->
        conn
        |> put_flash(:error, "Auto login link is invalid or expired.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  # magic link login
  defp create(conn, %{"user" => %{"token" => token} = user_params}, info) do
    case Accounts.login_user_by_magic_link(token) do
      {:ok, {user, tokens_to_disconnect}} ->
        UserAuth.disconnect_sessions(tokens_to_disconnect)

        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      _ ->
        conn
        |> put_flash(:error, "The link is invalid or it has expired.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  # email + password login
  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    current_password = Map.get(user_params, "current_password", "")
    password_attrs = Map.drop(user_params, ["current_password"])

    cond do
      not Accounts.valid_user_password?(user, current_password) ->
        conn
        |> put_flash(:error, "Current password is incorrect.")
        |> redirect(to: ~p"/account/password")

      true ->
        case Accounts.update_user_password(user, password_attrs) do
          {:ok, {updated_user, expired_tokens}} ->
            UserAuth.disconnect_sessions(expired_tokens)

            conn
            |> put_flash(:info, "Password updated successfully!")
            |> put_session(:user_return_to, ~p"/account")
            |> UserAuth.log_in_user(updated_user, params)

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Could not update password.")
            |> redirect(to: ~p"/account/password")
        end
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
