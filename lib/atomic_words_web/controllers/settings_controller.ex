defmodule AtomicWordsWeb.SettingsController do
  use AtomicWordsWeb, :controller

  def settings(conn, _params) do
    render(conn, "settings.html")
  end

  def update(conn, _params) do
    # Logic for updating user settings goes here
    conn
    |> put_flash(:info, "Settings updated successfully.")
    |> redirect(to: "/settings")
  end
end
