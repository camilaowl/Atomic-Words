defmodule AtomicWordsWeb.AuthController do
  use AtomicWordsWeb, :controller

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def sign_up(conn, _params) do
    render(conn, "sign_up.html")
  end

  def logout(conn, _params) do
    # Logic for logging out the user goes here
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/login")
  end

  def onboarding(conn, _params) do
    render(conn, "onboarding.html")
  end
end
