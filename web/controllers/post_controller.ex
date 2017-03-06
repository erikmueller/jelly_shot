alias Frozen.Repo
alias Frozen.PostView
alias Frozen.ErrorView

defmodule Frozen.PostController do
  use Frozen.Web, :controller

  def show(conn, %{"slug" => slug}) do
    case Repo.get_by_slug(slug) do
      {:ok, post} ->
        render PostView, "show.html", post: post
      {:not_found} ->
        conn |> put_status(:not_found) |> render(ErrorView, "404.html")
    end
  end
end
