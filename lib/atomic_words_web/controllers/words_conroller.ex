defmodule AtomicWordsWeb.WordsController do
  use AtomicWordsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
