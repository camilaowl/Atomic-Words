defmodule AtomicWordsWeb.PageController do
  alias AtomicWords.Repo
  use AtomicWordsWeb, :controller

  #alias AtomicWords.{Repo, Word}

  def home(conn, _params) do
    words = AtomicWords.Repo.all(AtomicWords.Word)
    render(conn, :home)
  end
end
