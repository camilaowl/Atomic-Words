defmodule AtomicWordsWeb.GoogleAuthController do
  use AtomicWordsWeb, :controller

  alias ElixirAuthGoogle.{GoogleOAuth, GoogleOAuthStrategy}
  alias AtomicWords.Accounts
  alias AtomicWordsWeb.UserAuth

  def request(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    redirect(conn, external: oauth_google_url)
  end

  def google_auth(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    redirect(conn, external: oauth_google_url)
  end

  def google_callback(conn, %{"code" => code}) do
    case GoogleOAuth.get_token!(code: code, strategy: GoogleOAuthStrategy) do
      %{access_token: access_token} ->
        # Here you would typically find or create the user in your database
        # For demonstration, we'll just put the access token in the session
        conn
        |> put_session(:google_access_token, access_token)
        |> put_flash(:info, "Successfully authenticated with Google!")
        |> redirect(to: "/")

      _ ->
        conn
        |> put_flash(:error, "Failed to authenticate with Google.")
        |> redirect(to: "/login")
    end
  end

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, AtomicWordsWeb.Endpoint.url())
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    case Accounts.get_or_create_user_from_google(profile) do
      {:ok, user} ->
        # Log the user in - this follows the UserAuth pattern
        conn
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failed to register with Google")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  # Fallback for requests without an OAuth `code` param.
  # Redirect the user to the OAuth authorization URL.
  def index(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    redirect(conn, external: oauth_google_url)
  end
end
