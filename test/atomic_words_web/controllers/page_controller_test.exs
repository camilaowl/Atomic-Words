defmodule AtomicWordsWeb.PageControllerTest do
  use AtomicWordsWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "The last added:"
  end
end
