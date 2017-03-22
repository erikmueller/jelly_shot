alias JellyShot.Repo
alias JellyShot.ErrorView

defmodule JellyShot.PostController do
  use JellyShot.Web, :controller

  def index(conn, params) do
    {tmpl, headline, {:ok, posts}} = case params do
      %{"author" => author} ->
        {"list", "posts by author",  Repo.get_by_author(author)}
      %{"category" => category} ->
        {"list", "posts by category", Repo.get_by_category(category)}
      _ ->
        {"index", "recent posts", Repo.list()}
    end

    render conn, "#{tmpl}.html", headline: headline, posts: posts
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
