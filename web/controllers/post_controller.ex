alias Frozen.Repo
alias Frozen.ErrorView

defmodule Frozen.PostController do
  use Frozen.Web, :controller

  def index(conn, _params) do
    {:ok, posts} = Repo.list()

    render conn, "index.html", posts: posts
  end

  def show(conn, %{"slug" => slug}) do
    case Repo.get_by_slug(slug) do
      {:ok, post} ->
        render conn, "show.html", post: post
      :not_found ->
        conn |> put_status(:not_found) |> render(ErrorView, "404.html")
    end
  end
end
