defmodule AtomicWordsWeb.StatsController do
  use AtomicWordsWeb, :controller

  def home(conn, _params) do
    render(conn, :statistics)
  end
end
