alias JellyShot.Repo

defmodule JellyShot.AuthorController do
  use JellyShot.Web, :controller

  def show(conn, %{"author" => author}) do
    {:ok, posts} = Repo.get_by_author(author)

    render conn, "show.html", posts: posts, author: author
  end
end
