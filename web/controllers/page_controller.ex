alias JellyShot.PageRepository, as: Page
alias JellyShot.ErrorView

defmodule JellyShot.PageController do
  use JellyShot.Web, :controller

  def show(conn, %{"slug" => file_name}) do
     case Page.get_by_file_name(file_name) do
      {:ok, page} ->
        render conn, "show.html", page: page, name: file_name
      :not_found ->
        conn |> put_status(:not_found) |> render(ErrorView, "404.html")
    end
  end
end
