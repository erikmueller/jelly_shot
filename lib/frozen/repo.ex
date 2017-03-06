defmodule Frozen.Repo do
  def start_link do
    Agent.start_link(&init/0, name: __MODULE__)
  end

  def init, do: Frozen.Crawler.ls

  def list() do
    Agent.get(__MODULE__, fn posts -> {:ok, posts} end)
  end

  def get_by_slug(slug) do
    Agent.get(__MODULE__, fn posts ->
      case Enum.find(posts, &(&1.slug == slug)) do
        nil -> :not_found
        post -> {:ok, post}
      end
    end)
  end

  def update_by_slug(slug) do
    file_name = "#{slug}.md"
    new_post = Frozen.Post.compile(file_name)

    IO.puts "Recompiled #{file_name}"

    Agent.update(__MODULE__, fn posts ->
      ix = Enum.find_index(posts, &(&1.slug == slug))

      if ix do
        List.replace_at(posts, ix, new_post)
      else
        IO.warn "Failed to compile #{file_name}. Not Found."
      end
    end)
  end
end
