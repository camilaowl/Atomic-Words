defmodule AtomicWordsWeb.WordsController do
  use AtomicWordsWeb, :controller

  def home(conn, _params) do
    render(conn, :words)
  end
end
