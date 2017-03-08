defmodule Frozen.LayoutView do
  use Frozen.Web, :view

  def render("meta.html", _assigns) do
    ~E"""
      <title>My blog</title>
      <meta name="author" content="Erik" />
      <meta name="description" content="Some smarty thoughts" />
      <link rel="canonical" href="https://blog.com" />
    """
  end

  def get_categories() do
    {:ok, posts} = Frozen.Repo.list()

    posts
      |> Enum.reduce([], fn (post, acc) -> acc ++ post.categories end)
      |> Enum.uniq
  end
end
