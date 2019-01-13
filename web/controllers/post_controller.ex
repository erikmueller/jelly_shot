alias JellyShot.PostRepository, as: Repo
alias JellyShot.ErrorView

defmodule JellyShot.PostController do
  use JellyShot.Web, :controller

  def index(conn, params) do
    page = Map.get(params, "page", "0") |> String.to_integer
    {tmpl, headline, {:ok, posts}} = case params do
      %{"author" => author} ->
        {"list", "posts by author",  Repo.get_by_author(author) |> Repo.page(page)}
      %{"category" => category} ->
        {"list", "posts by category", Repo.get_by_category(category) |> Repo.page(page)}
      _ ->
        {"index", "recent posts", Repo.list() |> Repo.page(page)}
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
