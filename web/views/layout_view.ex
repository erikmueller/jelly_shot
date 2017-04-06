alias JellyShot.PostRepository, as: Repo

defmodule JellyShot.LayoutView do
  use JellyShot.Web, :view

  def get_categories() do
    {:ok, posts} = Repo.list()

    posts
      |> Enum.reduce([], fn (post, acc) -> acc ++ post.categories end)
      |> Enum.uniq
  end
end
