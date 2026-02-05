defmodule AtomicWordsWeb.PageController do
  use AtomicWordsWeb, :controller

  def home(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    render(conn, :home, google_oauth_url: oauth_google_url)
  end
end
