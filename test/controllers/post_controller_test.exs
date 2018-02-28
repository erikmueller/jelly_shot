defmodule JellyShot.PostControllerTest do
  use JellyShot.ConnCase

  test "index", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "test intro"
  end

  test "show test_file", %{conn: conn} do
    conn = get conn, "/posts/test_file"
    assert html_response(conn, 200) =~ "test post"
  end

  test "list by author", %{conn: conn} do
    conn = get conn, "/posts?author=Erik"
    assert html_response(conn, 200) =~ "test post"
  end

  test "list by category", %{conn: conn} do
    conn = get conn, "/posts?category=test"
    assert html_response(conn, 200) =~ "test post"
  end

  test "not found", %{conn: conn} do
    conn = get conn, "/posts/not_found"
    assert html_response(conn, 404) =~ "Page not found"
  end
end
