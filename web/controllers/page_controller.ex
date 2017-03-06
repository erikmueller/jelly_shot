alias Frozen.Repo

defmodule Frozen.PageController do
  use Frozen.Web, :controller

  def index(conn, _params) do
    {:ok, posts} = Repo.list()
    render conn, "index.html", posts: posts
  end
end
