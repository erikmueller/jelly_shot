require Logger

alias JellyShot.Post

defmodule JellyShot.Repo do
  def start_link do
    Agent.start_link(&get_initial_state/0, name: __MODULE__)
  end

  def anew, do: Agent.update(__MODULE__, fn _ -> get_initial_state() end)

  def list do
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

    case Post.compile(file_name) do
      {:ok, new_post} ->
        Agent.update(__MODULE__, fn posts ->
          ix = Enum.find_index(posts, &(&1.slug == slug))

          if ix do
            Logger.info "Updated #{file_name} in #{Timex.diff Timex.now(), start, :milliseconds}ms."

            List.replace_at(posts, ix, new_post)
          else
            Logger.warn "Failed to update #{file_name}. Not Found."

            posts
          end
        end)
      {:error, reason} -> Logger.warn reason
    end
  end

  def delete_by_slug(slug) do
    file_name = "#{slug}.md"

    Agent.update(__MODULE__, fn posts ->
      ix = Enum.find_index(posts, &(&1.slug == slug))

      if ix do
        Logger.info "Removed #{file_name}"

        List.delete_at(posts, ix)
      else
        Logger.warn "Failed to remove #{file_name}. Not Found."

        posts
      end
    end)
  end

  def get_initial_state() do
    start = Timex.now()

    posts = File.ls!("priv/posts")
    |> Enum.filter(&(Path.extname(&1) == ".md"))
    |> Enum.map(&compile_async/1)
    |> Enum.map(&Task.await/1)
    |> Enum.reduce([], &aggregate_valid_posts/2)
    |> Enum.sort(&sort/2)

    Logger.debug "Compiled #{Enum.count(posts)} posts in #{Timex.diff Timex.now(), start, :milliseconds}ms."

    posts
  end

  defp compile_async(file), do: Task.async(fn -> Post.compile file end)

  defp aggregate_valid_posts(item, acc) do
    case item do
      {:ok, post} -> acc ++ [post]
      {:error, reason} ->
        Logger.warn reason
        acc
    end
  end

  defp sort(a, b) do
    date_a = a.date
    date_b = b.date

    if (
      date_a
      && date_b
      && Timex.is_valid? date_a
      && Timex.is_valid? date_b
    ), do: Timex.compare(date_a, date_b) > 0, else: true
  end
end
