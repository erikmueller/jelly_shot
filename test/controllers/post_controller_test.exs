defmodule JellyShot.PostControllerTest do
  use JellyShot.ConnCase

  test "GET /blog", %{conn: conn} do
    conn = get conn, "/blog"
    assert html_response(conn, 200) =~ "Dev Blog"
  end
end
