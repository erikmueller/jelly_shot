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
end
