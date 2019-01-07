alias JellyShot.PostRepository, as: Repo

defmodule JellyShot.LayoutView do
  use JellyShot.Web, :view

  def get_categories() do
    {:ok, categories} = Repo.categories()
    categories
    |> Map.keys 
  end
end
