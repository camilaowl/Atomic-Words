defmodule AtomicWordsWeb.StatsController do
  use AtomicWordsWeb, :controller

  def stats(conn, _params) do
    render(conn, "stats.html")
  end
end
