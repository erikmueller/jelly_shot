alias JellyShot.Repo

defmodule JellyShot.CategoryController do
  use JellyShot.Web, :controller

  def show(conn, %{"category" => category}) do
    {:ok, posts} = Repo.get_by_category(category)

    render conn, "show.html", posts: posts, category: category
  end
end
