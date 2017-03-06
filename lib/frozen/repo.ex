require Logger

alias Frozen.Post

defmodule Frozen.Repo do
  def start_link do
    Agent.start_link(&init/0, name: __MODULE__)
  end

  def init() do
    start = Timex.now()

    posts = File.ls!("priv/posts")
      |> Enum.filter(&(Path.extname(&1) == ".md"))
      |> Enum.map(&compile_async/1)
      |> Enum.map(&Task.await/1)
      |> Enum.sort(&sort/2)

      Logger.debug "Compiled #{Enum.count(posts)} posts in #{Timex.diff Timex.now(), start, :milliseconds}ms."

      posts
  end

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
    start = Timex.now()
    file_name = "#{slug}.md"
    new_post = file_name |> compile_async |> Task.await

    Logger.debug "Recompiled #{file_name} in #{Timex.diff Timex.now(), start, :milliseconds}ms."

    Agent.update(__MODULE__, fn posts ->
      ix = Enum.find_index(posts, &(&1.slug == slug))

      if ix do
        List.replace_at(posts, ix, new_post)
      else
        Logger.warn "Failed to compile #{file_name}. Not Found."
      end
    end)
  end

  defp compile_async(file), do: Task.async(fn -> Post.compile file end)

  defp sort(a, b) do
    date_a = a.date
    date_b = b.date

    if (Timex.is_valid? date_a && Timex.is_valid? date_b), do: Timex.compare(date_a, date_b) > 0
  end
end
