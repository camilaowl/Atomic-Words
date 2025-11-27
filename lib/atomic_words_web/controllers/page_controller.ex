defmodule AtomicWordsWeb.PageController do
  use AtomicWordsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
